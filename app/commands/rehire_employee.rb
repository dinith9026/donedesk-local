class RehireEmployee < ApplicationCommand
  def initialize(employee_record)
    @employee_record = employee_record
  end

  def call
    @employee_record.employed!
    broadcast(:ok, @employee_record)
  end
end
