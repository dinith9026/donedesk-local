class DocumentGroupsPresenter < CollectionPresenter
  def size
    @collection.size
  end

  def presets
    context.presets
  end

  def new_path(applies_to = 'employees')
    new_document_group_path(applies_to: applies_to)
  end
end
