class DocumentStatusPresenter < ModelPresenter
  presents :document_status

  delegate :is_confidential, :document_type, :document_type_id, :document_type_name, to: :document_status

  def user_can?(action)
    if document.present?
      presenter = presenter_for(document)
    else
      document = Document.new(document_type: document_status.document_type)
      owned_document = document_status.build_document(document)
      presenter = presenter_for(owned_document)
    end

    presenter.user_can?(action)
  end

  def when_user_can(action, &block)
    if user_can?(action)
      yield
    end
  end

  def name
    ApplicationController
      .helpers
      .document_type_display_name(document_status.document_type)
  end

  def status_class
    { 'Valid'    => 'text-bold-700',
      'Optional' => 'text-muted',
    }.fetch(status, '')
  end

  def status_color_class
    { 'Expiring Soon'    => 'warning',
      'Expired'          => 'danger',
      'Valid'            => 'primary',
      'Required/Missing' => 'grey',
    }.fetch(status, '')
  end

  def icon_type
    { 'Valid'    => 'check',
      'Optional' => 'blank',
    }.fetch(status, 'flag')
  end

  def status
    if document_status.document.present?
      document_status.document.status
    else
      if document_status.required
        'Required/Missing'
      else
        'Optional'
      end
    end
  end

  def when_document_visible(&block)
    if user_can?(:show)
      yield
    end
  end

  def when_document_downloadable(&block)
    if document.present? && user_can?(:download)
      yield
    end
  end

  def when_document_not_downloadable(&block)
    unless document.present? && user_can?(:download)
      yield
    end
  end

  def download_path
    download_document_path(document)
  end

  private

  def document
    @document ||= document_status.document
  end
end
