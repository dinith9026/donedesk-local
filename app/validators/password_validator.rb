class PasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return true if options[:allow_blank] && value.blank?

    failures = []

    unless value =~ /(?=.*[a-z])/
      failures << 'at least one lowercase letter'
    end

    unless value =~ /(?=.*[A-Z])/
      failures << 'at least one uppercase letter'
    end

    unless value =~ /(?=.*[0-9])/
      failures << 'at least one uppercase letter'
    end

    if failures.any?
      record.errors[attribute] << (options[:message] || "must contain #{failures.join(', ')}")
    end
  end
end
