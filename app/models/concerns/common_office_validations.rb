module CommonOfficeValidations
  extend ActiveSupport::Concern

  included do
    validates :name, :street_address, :city, :state, :zip, :phone, :time_zone, :document_group_id,
      presence: true
    validates :state, inclusion: { in: State::STATES.keys,
                                   message: "%{value} is not a valid state" }
    validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.all.map(&:name)
    validate :uniqueness_of_name_per_account

    private

    def uniqueness_of_name_per_account
      if account_offices_with_name.where.not(id: id).any?
        errors.add(:name, 'already taken')
      end
    end

    def account_offices_with_name
      AccountOfficesWithName.new(name, account_id).query
    end
  end
end
