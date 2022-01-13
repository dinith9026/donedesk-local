class AssignedTracksController < ApplicationController
  def create
    track = find_active_track
    authorize track, :assign?

    # Prevent cross-account access
    find_employee_records_with_employed_status

    @form = AssignTrackToEmployeesForm.new(
      employee_record_ids: params[:employee_record_ids],
      notify_employees: params[:notify_employees]
    )

    AssignTrackToEmployees.call(track, @form) do
      on(:ok) { |a_track| set_flash_success_and_redirect_to(a_track) }
      on(:invalid) { |a_track, error| set_flash_error_and_redirect_to(a_track, error) }
    end
  end

  def destroy
    assigned_track = find_assigned_track
    authorize assigned_track.track, :unassign?

    UnassignTrack.call(assigned_track) do
      on(:ok) { |a_track| set_flash_success_and_redirect_to(a_track) }
    end
  end

  private

  def find_active_track
    current_account.tracks.active.find(params[:track_id])
  end

  def find_assigned_track
    current_account.assigned_tracks.includes([:track, :courses]).find(params[:id])
  end

  def find_employee_records_with_employed_status
    current_account.employee_records.employed.find(params[:employee_record_ids])
  end
end
