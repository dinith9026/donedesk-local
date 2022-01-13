require 'active_record/fixtures'

module TestPasswordHelper
  def default_password_digest
    BCrypt::Password.create(default_password, cost: 4)
  end

  def default_password
    'Password1'
  end
end

ActiveRecord::FixtureSet.context_class.include TestPasswordHelper
