class LibraryDocumentPresenter < ModelPresenter
  presents :library_document
  delegate :name, :file_name, :summary, :is_canned?, :is_custom?, :is_visible_to_employees?,
            to: :library_document

  def when_existing_record(&block)
    if library_document.persisted?
      yield
    end
  end

  def visible_to_employees
    if library_document.is_visible_to_employees
      '<i class="icon icon-eye3"></i> YES'.html_safe
    else
      '<i class="icon icon-eye-blocked"></i> NO'.html_safe
    end
  end

  def type
    if library_document.is_custom?
      'My Documents'
    else
      'Other Documents'
    end
  end

  def created_at
    library_document.created_at.strftime('%Y-%m-%d')
  end

  def show_path
    library_document_path(library_document)
  end

  def edit_path
    edit_library_document_path(library_document)
  end

  def download_path
    download_library_document_path(library_document)
  end

  def destroy_path
    library_document_path(library_document)
  end
end
