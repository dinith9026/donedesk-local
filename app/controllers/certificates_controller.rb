class CertificatesController < ApplicationController
  def show
    certificate = find_certificate
    authorize certificate
    @certificate_presenter = CertificatePresenter.new(certificate, policy(certificate))

    render pdf: 'certificate',
           layout: 'certificate.pdf.erb',
           template: 'certificates/show.pdf.erb',
           orientation: 'Portrait'
  end

  private

  def find_certificate
    current_account.certificates.find(params[:id])
  end
end
