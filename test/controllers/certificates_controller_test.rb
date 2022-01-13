require 'test_helper'

class CertificatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @assignment = assignments(:oceanview_passed)
    @other_assignment = assignments(:brookside_handbook)
    @certificate = certificates(:for_oceanview_ed)
    @other_certificate = certificates(:for_brookside_ellen)

    create(:certificate, course: @assignment.course, employee_record: @assignment.employee_record)
  end

  describe '#show' do
    it_requires_authenticated_user { get certificate_url(@certificate) }

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test 'when certificate does NOT belong to their account' do
          get certificate_url(@other_certificate, as: users(role))

          assert_redirects_with_not_found_error
        end

        test 'when certificate belongs to their account' do
          get certificate_url(@certificate, as: users(role))

          assert_response :success
          assert_includes assigns.keys, 'certificate_presenter'
          assert_template 'certificates/show.pdf.erb'
          assert_includes content_type, 'application/pdf'
        end
      end
    end

    describe 'for employee' do
      test 'when certificate does NOT belong to them' do
        certificate = certificates(:for_oceanview_eric)

        get certificate_url(certificate, as: users(:employee))

        assert_redirects_with_not_authorized_error
      end

      test 'when certificate belongs to them' do
        get certificate_url(@certificate, as: users(:employee))

        assert_response :success
        assert_includes assigns.keys, 'certificate_presenter'
        assert_template 'certificates/show.pdf.erb'
        assert_includes content_type, 'application/pdf'
      end
    end
  end

  private

  def content_type
    response.headers['Content-Type']
  end
end
