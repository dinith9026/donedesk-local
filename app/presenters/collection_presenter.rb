class CollectionPresenter < BasePresenter
  include Enumerable

  attr_reader :collection, :context, :current_user, :policy

  delegate :total_pages, :current_page, :limit_value, to: :collection

  def initialize(collection, current_user, policy = nil)
    @collection = collection
    @current_user = current_user
    @policy = policy
    @context = nil
  end

  def each(&block)
    @collection.each { |model| yield presenter_class_for(model) }
  end

  def include?(item)
    @collection.include?(item)
  end

  def with_context(new_context)
    @context = if new_context.is_a?(Hash)
                 OpenStruct.new(new_context)
               else
                 new_context
               end

    self
  end

  private

  def policy_for(model)
    klass = @policy_class || "#{model.class}Policy".constantize
    klass.new(@current_user, model)
  end

  def presenter_class_for(model)
    klass = "#{model.class}Presenter".constantize
    klass.new(model, policy_for(model))
  end
end
