module Personable
  extend ActiveSupport::Concern

  def full_name
    "#{first_name} #{last_name}"
  end

  def last_comma_first
    "#{last_name}, #{first_name}"
  end

  def first_initial_and_last
    "#{first_initial}. #{last_name}"
  end

  private

  def first_initial
    first_name[0,1]
  end
end
