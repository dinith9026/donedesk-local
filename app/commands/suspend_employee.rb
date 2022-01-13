class SuspendEmployee < ApplicationCommand
  def initialize(employee_record)
    @employee_record = employee_record
  end

  def call
    transaction do
      @employee_record.suspended!
      @employee_record.assignments.destroy_all
      @employee_record.assigned_tracks.destroy_all
    end

    broadcast(:ok)
  end
end
