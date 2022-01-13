class CertificatePresenter < ModelPresenter
  presents :certificate

  delegate :account_name, :passed_on, :expires_on, :full_name, :course_title, :course_certificate_type,
    :agd_member_number, to: :certificate

  def expiration
    if expires_on.blank?
      ''
    elsif expires_on < Date.current
      content_tag(:span, "#{expires_on}", class: 'text-danger')
    else
      expires_on
    end
  end

  def show_path
    certificate_path(certificate)
  end
end
