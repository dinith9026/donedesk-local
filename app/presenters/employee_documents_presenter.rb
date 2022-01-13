class EmployeeDocumentsPresenter < CollectionPresenter
  def documents_presenter
    DocumentsPresenter.new(self.map(&:document), current_user, policy)
  end
end
