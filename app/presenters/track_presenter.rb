class TrackPresenter < ModelPresenter
  presents :track

  delegate :name, :active?, :deactivated?, :courses,
    :employee_record_last_comma_first, to: :track

  def unassigned_courses
    context[:unassigned_courses].select { |course| course.assignable? }
  end

  def unassigned_employees
    context[:unassigned_employees]
  end

  def assigned_tracks
    context[:assigned_tracks]
  end

  def assigned_tracks_count
    context[:assigned_tracks_count]
  end

  def confirm_deactivate_message
    "Are you sure?\n\nNOTE: This action will NOT deactivate the courses.\n\n" \
    "IMPORTANT: All employees assigned to this track will no longer be assigned to any of " \
    "the courses unless the course is part of another track. For single course " \
    "assignments, you'll need to reassign the course."
  end

  def assigned_tracks_presenter
    AssignedTracksPresenter.new(assigned_tracks, current_user)
  end

  def when_show_enabled_remove_course_btn(&block)
    if show_enabled_remove_course_btn
      yield
    end
  end

  def when_show_disabled_remove_course_btn(&block)
    if show_disabled_remove_course_btn
      yield
    end
  end

  def when_unassigned_courses_exist(&block)
    if unassigned_courses.any?
      yield
    end
  end

  def when_no_unassigned_courses_exist(&block)
    if unassigned_courses.empty?
      yield
    end
  end

  def when_unassigned_employees_exist(&block)
    if unassigned_employees.any?
      yield
    end
  end

  def when_no_unassigned_employees_exist(&block)
    if unassigned_employees.empty?
      yield
    end
  end

  def created_at
    I18n.localize(track.created_at, format: '%Y-%m-%d %l:%M %p %Z')
  end

  def updated_at
    I18n.localize(track.updated_at, format: '%Y-%m-%d %l:%M %p %Z')
  end

  def total_active_courses
    track.courses.select { |course| course.active? }.size
  end

  def total_employed_employees_assigned
    track.employed_employee_records.size
  end

  def show_path
    track_path(track)
  end

  def edit_path
    edit_track_path(track)
  end

  def add_courses_path
    track_courses_path(track_id: track.id)
  end

  def create_assigned_track_path
    track_assigned_tracks_path(track)
  end

  def destroy_path
    track_path(track)
  end

  def deactivate_path
    deactivate_track_path(track)
  end

  def reactivate_path
    reactivate_track_path(track)
  end

  private

  def show_enabled_remove_course_btn
    user_can?(:remove_course) && track.active?
  end

  def show_disabled_remove_course_btn
    !user_can?(:remove_course) && track.active?
  end
end
