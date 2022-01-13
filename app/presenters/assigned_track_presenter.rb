class AssignedTrackPresenter < ModelPresenter
  presents :assigned_track

  delegate :employee_record_last_comma_first, :progress, to: :assigned_track

  def show_employee_record_path
    employee_record_path(assigned_track.employee_record)
  end

  def destroy_path
    assigned_track_path(assigned_track)
  end
end
