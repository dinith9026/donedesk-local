require 'test_helper'

class CertificatetPresenterTest < ActiveSupport::TestCase
  subject { CertificatePresenter.new(nil, nil) }

  should delegate_method(:passed_on).to(:certificate)
  should delegate_method(:expires_on).to(:certificate)
  should delegate_method(:full_name).to(:certificate)
  should delegate_method(:course_title).to(:certificate)

  describe '#expiration' do
    test 'when expired' do
      certificate = build(:certificate, :expired)
      subject = CertificatePresenter.new(certificate, nil)

      assert "<span class=\"text-danger\">expired #{certificate.expires_on}</span>", subject.expiration
    end

    test 'when NOT expired' do
      certificate = build(:certificate)

      subject = CertificatePresenter.new(certificate, nil)

      assert "expires #{certificate.expires_on}", subject.expiration
    end
  end

  test 'paths' do
    employee_record = build(:employee_record, id: SecureRandom.uuid)
    course = build(:course, id: SecureRandom.uuid)
    certificate = build(
      :assignment,
      id: SecureRandom.uuid,
      employee_record: employee_record,
      course: course)
    subject = CertificatePresenter.new(certificate, nil)

    refute_nil subject.show_path
  end
end
