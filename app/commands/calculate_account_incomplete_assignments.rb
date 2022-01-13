class CalculateAccountIncompleteAssignments < ApplicationCommand
  def initialize(account)
    @account = account
  end

  def call
    IncompleteAssignment.where(assignment_id: @account.assignments.ids).destroy_all

    @account.incomplete_assignments.each do |assignment|
      IncompleteAssignment.create!(
        assignment_id: assignment.id,
        status: assignment.state,
        due_date: assignment.due_date
      )
    end

    broadcast(:ok)
  end
end
