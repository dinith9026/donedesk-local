class MarkAssignmentCompleted < ApplicationCommand
  def initialize(assignment, passed_on)
    @assignment = assignment
    @passed_on = passed_on
  end

  def call
    transaction do
      @assignment.mark_completed!
      @assignment.create_certificate!(@passed_on)
    end

    broadcast(:ok)
  end
end
