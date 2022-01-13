module Deactivateable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(deactivated_at: nil) }
    scope :deactivated, -> { where.not(deactivated_at: nil) }

    def active?
      deactivated_at.nil?
    end

    def deactivated?
      !active?
    end

    def deactivate!
      touch(:deactivated_at)
    end

    def reactivate!
      update!(deactivated_at: nil)
    end
  end
end
