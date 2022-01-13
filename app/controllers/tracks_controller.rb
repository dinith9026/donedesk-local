class TracksController < ApplicationController
  def index
    authorize Track
    tracks =
      current_account
      .tracks
      .includes([:courses])
      .order(:name)

    @tracks_presenter =
      TracksPresenter
      .new(tracks, current_user, policy(Track))
      .with_context(presets: TrackPreset.all)
  end

  def new
    authorize Track
    @form = TrackForm.new.with_context(courses: current_account.courses.active)
  end

  def create
    authorize Track
    @form =
      TrackForm
      .from_params(track_params_for_create, account_id: current_account.id)
      .with_context(courses: current_account.courses)

    CreateTrack.call(@form) do
      on(:ok)      { |track| set_flash_success_and_redirect_to(track) }
      on(:invalid) { set_flash_error_and_render(:new) }
    end
  end

  def show
    @track = find_track
    authorize @track
    unassigned_courses = current_account.courses.active.includes(:questions) - @track.courses

    employee_records = current_account.unassigned_employees_for_track(@track)
    unassigned_employees = EmployeeRecordsPresenter.new(employee_records, current_user).group_by do |erp|
      erp.office_name
    end.sort_by { |k, v| k }.to_h

    assigned_tracks = @track.assigned_tracks_for_employed_employees
    assigned_tracks_count = assigned_tracks.size
    assigned_tracks_paged = assigned_tracks.page(params[:page]).per(10)

    @track_presenter =
      TrackPresenter
      .new(@track, policy(@track))
      .with_context(
        unassigned_courses: unassigned_courses,
        unassigned_employees: unassigned_employees,
        assigned_tracks_count: assigned_tracks_count,
        assigned_tracks: assigned_tracks_paged
    )
  end

  def edit
    track = find_track
    authorize track
    @form = TrackForm.from_model(track).with_context(courses: current_account.courses)
  end

  def update
   track = find_track
    authorize track
    @form =
      TrackForm
      .from_model(track)
      .with_context(courses: current_account.courses)
    @form.attributes = track_params_for_update.to_h

    if @form.valid?
      track.update!(@form.attributes)
      set_flash_success_and_redirect_to(track)
    else
      set_flash_error_and_render(:edit)
    end
  end

  def destroy
    track = find_track
    authorize track

    DeleteTrack.call(track) do
      on(:ok) { set_flash_success_and_redirect_to(tracks_url) }
    end
  end

  def deactivate
    track = find_active_track
    authorize track

    DeactivateTrack.call(track) do
      on(:ok) { |a_track| set_flash_success_and_redirect_to(a_track) }
    end
  end

  def reactivate
    track = current_account.tracks.deactivated.find(params[:id])
    authorize track

    ReactivateTrack.call(track) do
      on(:ok) { |a_track| set_flash_success_and_redirect_to(a_track) }
    end
  end

  private

  def find_active_track
    current_account.tracks.active.includes([:courses, :employee_records]).find(params[:id])
  end

  def find_track
    current_account.tracks.includes([:courses, [assigned_tracks: :employee_record]]).find(params[:id])
  end

  def track_params_for_create
    params.require(:track).permit(:name, course_ids: [])
  end

  def track_params_for_update
    params.require(:track).permit(:name)
  end
end
