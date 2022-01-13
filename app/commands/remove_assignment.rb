class RemoveAssignment < ApplicationCommand
  def initialize(assignment)
    @assignment = assignment
  end

  def call
    @assignment.destroy!
    broadcast(:ok)
  end
end
