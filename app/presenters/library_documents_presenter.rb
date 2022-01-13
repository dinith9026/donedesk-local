class LibraryDocumentsPresenter < CollectionPresenter
  def custom
    select do |library_document_presenter|
      library_document_presenter.is_custom?
    end
  end

  def canned
    select do |library_document_presenter|
      library_document_presenter.is_canned?
    end
  end
end
