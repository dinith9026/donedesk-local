require 'test_helper'

class InvitesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @authorized_user = users(:account_owner)
    @employee_record = employee_records(:with_no_user)
    @another_employee_record = employee_records(:ellen)
  end

  describe '#create' do
    it_requires_authenticated_user { post employee_record_invites_url(@employee_record) }

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test 'when employee record does NOT belong to account' do
          user = users(role)

          post employee_record_invites_url(@another_employee_record, as: user,
                                           params: { invite: valid_params })

          assert_redirects_with_not_found_error
        end

        test 'when params are invalid' do
          user = users(role)

          assert_no_difference 'User.count' do
            perform_enqueued_jobs do
              post employee_record_invites_url(@employee_record, as: user,
                                               params: { invite: invalid_params })
            end
          end
          assert_response :success
          assert_template :new
          assert_empty ActionMailer::Base.deliveries
        end

        test 'when params are valid' do
          user = users(role)

          assert_difference 'User.count', 1 do
            perform_enqueued_jobs do
              post employee_record_invites_url(@employee_record, as: user,
                                               params: { invite: valid_params })
            end
          end
          assert_response :redirect
          refute_nil flash[:success]
          assert_match(/Invite: .+ DoneDesk/i, last_email.subject)
          assert_equal valid_params[:role], last_user.role
        end
      end
    end

    test 'for employee' do
      post employee_record_invites_url(@employee_record, as: users(:employee),
                                       params: { invite: valid_params })

      assert_redirects_with_not_authorized_error
    end
  end

  private

  def valid_params
    attributes_for(:invite, role: 'employee')
  end

  def invalid_params
    valid_params.merge(email: '')
  end

  def last_user
    User.order(:created_at).last
  end
end
