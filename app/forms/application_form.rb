class ApplicationForm < Rectify::Form
  include Rails.application.routes.url_helpers
  include PresenterHelpers

  attr_reader :policy

  def with_policy(policy)
    @policy = policy
    self
  end

  def attributes
    if policy && policy.respond_to?(:permitted_attributes)
      super.slice(*policy.permitted_attributes)
    else
      super
    end
  end

  def new_record?
    !persisted?
  end

  def persisted?
    id.present?
  end

  def error_messages(sep = ', ')
    errors.full_messages.join(sep)
  end

  def merge_errors_for(attr, field_prefix = '')
    field_prefix = field_prefix.presence || attr.to_s

    public_send(attr.to_s).errors.messages.each do |field, errors_array|
      errors_array.each do |error_message|
        errors.add("#{field_prefix}_#{field}", error_message)
      end
    end
  end
end
