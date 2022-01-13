class ModelPresenter < BasePresenter
  attr_reader :policy, :opts, :context

  def initialize(object, policy, opts={})
    @object = object
    @policy = policy
    @opts = opts
  end

  def current_user
    policy.user
  end

  def presenter_for(object)
    policy_class = "#{object.class}Policy".constantize
    policy_object = policy_class.new(policy.user, object)
    presenter_class = "#{object.class}Presenter".constantize

    presenter_class.new(object, policy_object)
  end

  def id
    @object.id
  end

  def with_context(context)
    @context = context
    self
  end

  private

  def self.presents(name)
    define_method(name) do
      @object
    end
  end

  def self.titleize(*fields)
    fields.each do |field|
      define_method(field) do
        "#{@object.public_send(field)}".titleize
      end
    end
  end
end
