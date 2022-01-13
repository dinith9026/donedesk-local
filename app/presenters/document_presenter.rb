class DocumentPresenter < ModelPresenter
  presents :document
  delegate :id, :summary, :file_name, :employee_record, :employee_record_full_name,
            to: :document

  def presenter_for_belongs_to
    @presenter_for_belongs_to ||= presenter_for(context[:belongs_to])
  end

  def when_user_can_download(&block)
    if presenter_for_belongs_to.user_can?(:download)
      yield
    end
  end

  def when_user_can_manage(&block)
    if presenter_for_belongs_to.user_can_manage?
      yield
    end
  end

  def name
    ApplicationController
      .helpers
      .document_type_display_name(document.document_type)
  end

  def expiration
    if document.expirable? && document.expired?
      content_tag(:span, class: "text-danger") do
        "expired on #{expires_on}"
      end
    elsif document.expirable?
      "expires on #{expires_on}"
    else
      'no expiration'
    end
  end

  def expires_on
    if document.expirable?
      I18n.localize(document.expires_on.to_date, format: :default)
    else
      ''
    end
  end

  def created_at
    I18n.localize(document.created_at.to_date, format: :default)
  end

  def download_path
    presenter_for_belongs_to.download_path
  end
end
