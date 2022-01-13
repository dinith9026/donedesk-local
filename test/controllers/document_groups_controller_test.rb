require 'test_helper'

class DocumentGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:oceanview_dental)

    create_document_group_preset

    @document_group = document_groups(:oceanview_default)
    @other_document_group = document_groups(:brookside_default)

    @oceanview_performance_review = document_types(:oceanview_performance_review)
    @brookside_performance_review = document_types(:brookside_performance_review)
  end

  describe '#index' do
    it_requires_authenticated_user { get document_groups_url }

    [:account_owner, :account_manager].each do |role|
      test "as #{role}" do
        ed = employee_records(:ed).suspended!
        eric = employee_records(:eric).terminated!
        mary = employee_records(:mary)

        get document_groups_url(as: users(role))

        assert_response :success
        assert_includes assigns.keys, 'document_groups_presenter'
        assert_equal @account.document_groups.size, assigns[:document_groups_presenter].size
        assert_includes assigns[:document_groups_presenter], document_groups(:oceanview_default)
        refute_includes assigns[:document_groups_presenter], document_groups(:brookside_default)
        assert_includes assigns[:document_groups_presenter].first.employee_records, mary
        refute_includes assigns[:document_groups_presenter].first.employee_records, ed
        refute_includes assigns[:document_groups_presenter].first.employee_records, eric
      end
    end

    test 'for employee' do
      get document_groups_url(as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#new' do
    it_requires_authenticated_user { get new_document_group_url }

    [:account_owner, :account_manager].each do |role|
      test "as #{role}" do
        get new_document_group_url(as: users(role))

        assert_response :success
        assert_includes assigns.keys, 'form'
        assert_includes assigns[:form].document_types, document_types(:w4)
        assert_includes assigns[:form].document_types, @oceanview_performance_review
        refute_includes assigns[:form].document_types, @brookside_performance_review
      end
    end

    test 'for employee' do
      get new_document_group_url(as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#create' do
    it_requires_authenticated_user { post document_groups_url }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when params are invalid' do
          assert_no_difference ['DocumentGroup.count', 'DocumentTypesGrouping.count'] do
            post document_groups_url(as: users(role)), params: { document_group: { name: '' } }
          end
          assert_response :success
          assert_template :new
          assert_includes assigns.keys, 'form'
          assert_includes assigns[:form].document_types, @oceanview_performance_review
          refute_includes assigns[:form].document_types, @brookside_performance_review
        end

        test 'when params are valid' do
          user = users(role)
          name = SecureRandom.hex
          w4 = document_types(:w4)
          agreements = document_types(:agreements)
          valid_params = {
            document_group: {
              name: name,
              document_types_groupings: [
                { document_type_id: w4.id, required: true },
                { document_type_id: agreements.id }
              ]
            }
          }

          assert_differences([['DocumentGroup.count', 1], ['DocumentTypesGrouping.count', 2]]) do
            post document_groups_url(as: user), params: valid_params
          end

          new_document_group = DocumentGroup.find_by(name: name)

          assert_redirects_with_flash_success(document_group_path(new_document_group))
          assert_equal name, new_document_group.name
          assert_equal user.account_id, new_document_group.account_id
          assert_equal true, grouping_for(new_document_group, w4).required
          assert_equal false, grouping_for(new_document_group, agreements).required
        end

        test 'for employee' do
          post document_groups_url(as: users(:employee))

          assert_redirects_with_not_authorized_error
        end
      end
    end
  end

  describe '#show' do
    it_requires_authenticated_user { get document_group_url(@document_group) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when document group record does NOT belong to their account' do
          get document_group_url(@other_document_group, as: users(role))

          assert_redirects_with_not_found_error
        end

        test 'when document group record belongs to their account' do
          get document_group_url(@document_group, as: users(role))

          assert_response :success
          assert_includes assigns.keys, 'document_group_presenter'
        end
      end
    end

    test 'for employee' do
      get document_group_url(@document_group, as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#edit' do
    it_requires_authenticated_user { get edit_document_group_url(@document_group) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when document group record does NOT belong to their account' do
          get edit_document_group_url(@other_document_group, as: users(role))

          assert_redirects_with_not_found_error
        end

        test 'when document group record belongs to their account' do
          get edit_document_group_url(@document_group, as: users(role))

          assert_response :success
          assert_includes assigns.keys, 'form'
        end
      end
    end

    test 'for employee' do
      get edit_document_group_url(@document_group, as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#update' do
    it_requires_authenticated_user { put document_group_url(@document_group) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when document group record does NOT belong to their account' do
          put document_group_url(@other_document_group, as: users(role))

          assert_redirects_with_not_found_error
        end

        describe 'when document group record belongs to their account' do
          test 'with invalid params' do
            name = SecureRandom.hex
            create_employee_document_group_for(@account, name)
            invalid_params = { document_group: { name: name } }

            put document_group_url(@document_group, as: users(role)), params: invalid_params

            assert_response :success
            assert_template :edit
            assert_includes assigns.keys, 'form'
            assert_includes assigns[:form].document_types, @oceanview_performance_review
            refute_includes assigns[:form].document_types, @brookside_performance_review
          end

          test 'with valid params' do
            new_name = SecureRandom.hex
            # Make required opposite of current value to test updating it
            dtg_params = @document_group.document_types_groupings.map do |dtg|
              { document_type_id: dtg.document_type_id, required: !dtg.required }
            end
            # Remove one to test removal
            dtg_params.pop
            valid_params = {
              document_group: {
                name: new_name,
                document_types_groupings: dtg_params
              }
            }

            assert_difference 'DocumentTypesGrouping.count', -1 do
              put document_group_url(@document_group, as: users(role)), params: valid_params
            end

            @document_group.reload

            assert_redirects_with_flash_success(document_group_path(@document_group))
            assert_equal new_name, @document_group.name
            assert_equal @document_group.document_types_groupings.count, dtg_params.count
            @document_group.document_types_groupings.each do |dtg|
              assert_includes dtg_params, { document_type_id: dtg.document_type_id, required: dtg.required }
            end
          end
        end
      end
    end

    test 'for employee' do
      put document_group_url(@document_group, as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#assign' do
    it_requires_authenticated_user { post assign_document_group_url(@document_group) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when document group record does NOT belong to their account' do
          post assign_document_group_url(@other_document_group, as: users(role))

          assert_redirects_with_not_found_error
        end

        describe 'when document group record belongs to their account' do
          test 'when no employees selected' do
            post assign_document_group_url(@document_group, as: users(role))

            assert_redirects_with_flash_error(document_group_path(@document_group))
          end

          test 'when at least one employee selected' do
            new_document_group = create_employee_document_group_for(@account, 'Hygenists')
            ed = employee_records(:ed)
            eric = employee_records(:eric)
            params = {
              employee_record_ids: [ ed.id, eric.id ]
            }

            post assign_document_group_url(new_document_group, as: users(role)), params: params

            assert_redirects_with_flash_success(document_group_path(new_document_group))
            assert_equal new_document_group.id, ed.reload.document_group_id
            assert_equal new_document_group.id, eric.reload.document_group_id
          end
        end
      end
    end

    test 'for employee' do
      post assign_document_group_url(@document_group, as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#copy' do
    it_requires_authenticated_user { get copy_document_group_url(@document_group) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when document group record does NOT belong to their account' do
          get copy_document_group_url(@other_document_group, as: users(role))

          assert_redirects_with_not_found_error
        end

        test 'when document group record belongs to their account' do
          get copy_document_group_url(@document_group, as: users(role))

          assert_response :success
          assert_template :copy
          assert_includes assigns.keys, 'form'
          assert_includes assigns[:form].document_types, @oceanview_performance_review
          refute_includes assigns[:form].document_types, @brookside_performance_review
        end
      end
    end

    test 'for employee' do
      get copy_document_group_url(@document_group, as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#reassign' do
    it_requires_authenticated_user { get reassign_document_group_url(@document_group) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when document group record does NOT belong to their account' do
          get reassign_document_group_url(@other_document_group, as: users(role))

          assert_redirects_with_not_found_error
        end

        describe 'when document group record belongs to their account' do
          test 'and only one document group record exists' do
            user = users(role)

            get document_groups_url(as: user)

            get reassign_document_group_url(@document_group, as: user)

            assert_redirects_with_flash_warning(document_groups_path)
          end

          test 'and more than one document group record exists' do
            new_document_group = create_employee_document_group_for(@account, 'Hygenists')

            get reassign_document_group_url(@document_group, as: users(role))

            assert_response :success
            assert_template :reassign
            assert_includes assigns.keys, 'document_group'
            assert_includes assigns.keys, 'all_groups'
            assert_includes assigns[:all_groups], new_document_group
            refute_includes assigns[:all_groups], @document_group
          end
        end
      end
    end

    test 'for employee' do
      get reassign_document_group_url(@document_group, as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#destroy' do
    it_requires_authenticated_user { delete document_group_url(@document_group) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when document group record does NOT belong to their account' do
          delete document_group_url(@other_document_group, as: users(role))

          assert_redirects_with_not_found_error
        end

        describe 'when document group record belongs to their account' do
          test 'and employees are assigned but document group to reassign to is invalid' do
            delete document_group_url(@other_document_group, as: users(role)),
              params: { group_id: @other_document_group }

            assert_redirects_with_not_found_error
          end

          test 'and employees are assigned and group_id params is blank' do
            delete document_group_url(@document_group, as: users(role)),
              params: { group_id: nil }

            assert_redirected_to reassign_document_group_path(@document_group)
          end

          test 'and employees are assigned and document group to reassign to is valid' do
            new_document_group = create_employee_document_group_for(@account, 'Hygenists')
            employee_records = @document_group.employee_records
            expected_differences = [
              ['DocumentGroup.count', -1],
              [
                'DocumentTypesGrouping.count',
                @document_group.document_types_groupings.count * -1
              ]
            ]

            assert_differences(expected_differences) do
              delete document_group_url(@document_group, as: users(role)),
                params: { group_id: new_document_group.id }
            end
            assert_redirects_with_flash_success(document_groups_path(applies_to: 'employees'))
            employee_records.each do |employee_record|
              assert_equal new_document_group.id, employee_record.document_group_id
            end
          end

          test 'and no employees are assigned' do
            new_document_group = create_employee_document_group_for(@account, 'Hygenists')
            expected_differences = [
              ['DocumentGroup.count', -1],
              [
                'DocumentTypesGrouping.count',
                new_document_group.document_types_groupings.count * -1
              ]
            ]

            assert_differences(expected_differences) do
              delete document_group_url(new_document_group, as: users(role))
            end
            assert_redirects_with_flash_success(document_groups_path(applies_to: 'employees'))
          end
        end
      end
    end

    test 'for employee' do
      delete document_group_url(@document_group, as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  private

  def grouping_for(document_group, document_type)
    document_group.document_types_groupings.find do |dtg|
      dtg.document_type_id == document_type.id
    end
  end
end
