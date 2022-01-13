class AssignmentsController < ApplicationController
  def index
    authorize Assignment
    employee_record = EmployeeRecord.includes([assignments: [:course, :exams], assigned_tracks: [track: [courses_tracks: :course]]]).find(current_user.employee_record.id)
    @employee_record_presenter =
      EmployeeRecordPresenter.new(employee_record, policy(employee_record))
  end

  def show
    assignment = find_assignment
    authorize assignment
    @assignment_presenter = AssignmentPresenter.new(assignment, policy(assignment))
  end

  def mark_completed
    assignment = Assignment.find(params[:id])
    authorize assignment
    error = params[:passed_on].present? ? !helpers.valid_date?(params[:passed_on]) : false

    if error
      set_flash_error_and_redirect_to(smart_back_path, 'Invalid date format. Expected: mm/dd/yyyy')
    else
      passed_on = params[:passed_on].present? ? Date.strptime(params[:passed_on], "%m/%d/%Y") : Date.current

      MarkAssignmentCompleted.call(assignment, passed_on) do
        on(:ok) { set_flash_success_and_redirect_to(smart_back_path) }
      end
    end
  end

  def download
    @assignment = find_assignment
    authorize @assignment

    redirect_to @assignment.course_material_url
  end

  def destroy
    assignment = FindAssignmentForAccount.new(current_account, params[:id]).query
    authorize assignment

    RemoveAssignment.call(assignment) do
      on(:ok) { set_flash_success_and_redirect_to(smart_back_path) }
    end
  end

  private

  def find_assignment
    FindAssignmentForEmployee.new(employee_record_id, params[:id]).query
  end

  def employee_record_id
    current_user.employee_record_id
  end
end
