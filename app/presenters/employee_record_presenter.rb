class EmployeeRecordPresenter < ModelPresenter
  presents :employee_record
  delegate :emergency_contact_phone, :emergency_contact_email, :document_for,
           :phone, :status, :has_missing_or_expired_documents_cached?, :id, :user_id,
           :user_email, :employed?, :suspended?, :terminated?, :last_comma_first,
           :user_gravatar_url, :document_group_name, :agd_member_number,
            to: :employee_record
  titleize :emergency_contact_relationship, :emergency_contact_name,
           :title, :marital_status, :full_name, :office_name,
           :employment_type

  def initialize(object, policy, opts={})
    @object = object
    @policy = policy
    @opts = default_opts.merge(opts)
    super(@object, @policy, @opts)
  end

  def datatables_row_group_src
    user_can?(:take_assignments) ? 1 : 0
  end

  def datatables_order_fixed
    user_can?(:take_assignments) ? 1 : 0
  end

  def datatables_order
    user_can?(:take_assignments) ? 1 : 0
  end

  def can_notify?
    employee_record.has_login?
  end

  def when_has_login(&block)
    if employee_record.has_login?
      yield
    end
  end

  def when_has_no_login(&block)
    if !employee_record.has_login?
      yield
    end
  end

  def when_terminated(&block)
    if employee_record.terminated?
      yield
    end
  end

  def documents_presenter
    DocumentsPresenter.new(employee_record.employee_documents, current_user)
  end

  def certificates_presenter
    certificates =
      employee_record
      .certificates
      .includes(:course)
      .order('courses.title, expires_on DESC, certificates.created_at')

    CertificatesPresenter.new(certificates, current_user)
  end

  def assigned_offices
    @assigned_offices ||= employee_record.assigned_offices.map do |office|
      presenter_for(office)
    end
  end

  def unassigned_offices
    (context[:current_account].offices - employee_record.assigned_offices).sort_by(&:name)
  end

  def user
    employee_record.user
  end

  def user_presenter
    presenter_for(employee_record.user)
  end

  def terminated_on
    if employee_record.terminated_on.present?
      I18n.l(employee_record.terminated_on.to_date, format: :default)
    else
      ''
    end
  end

  def hired_on
    if employee_record.hired_on.present?
      I18n.l(employee_record.hired_on.to_date, format: :default)
    else
      ''
    end
  end

  def dob
    if employee_record.dob.present?
      I18n.l(employee_record.dob.to_date, format: :default)
    else
      ""
    end
  end

  def address
    if employee_record.address.present?
      simple_format(employee_record.address, {}, wrapper_tag: 'div')
    else
      ''
    end
  end

  def documents_status_icon
    if has_missing_or_expired_documents_cached?
      content_tag(:i, '', class: 'icon-flag warning')
    else
      content_tag(:i, '', class: 'icon-check info')
    end
  end

  def documents_status
    if has_missing_or_expired_documents_cached?
      'Missing/expired documents'
    else
      'All documents valid'
    end
  end

  def account_admin?
    employee_record.user_account_admin?
  end

  def each_available_document_type(&block)
    employee_record.available_document_types.each do |document_type|
      yield(presenter_for(document_type))
    end
  end

  def assignable_courses
    CoursesPresenter.new(employee_record.assignable_courses, current_user)
  end

  def assignable_tracks
    TracksPresenter.new(employee_record.assignable_tracks, current_user)
  end

  def active_assignments_grouped
    active_assignments = employee_record.active_assignments

    assignments = {'Single Courses' => []}

    # single courses
    active_assignments.each do |assignment|
      if assignment.active_tracks.empty?
        assignments['Single Courses'] << presenter_for(assignment)
      end
    end

    # tracks
    employee_record.assigned_tracks.each do |assigned_track|
      next unless assigned_track.track_active?

      assignments[assigned_track.track_name] ||= []

      assigned_track.track.courses_tracks.order(position: :asc).each do |course_track|
        course = course_track.course

        assignment = active_assignments.find { |a| a.course_id == course.id }
        assignment_presenter = presenter_for(assignment)
        assignment_presenter.maybe_track = assigned_track.track
        assignments[assigned_track.track_name] << assignment_presenter
      end
    end

    assignments
  end

  def employee_notes
    EmployeeNotesPresenter.new(employee_record.employee_notes, current_user)
  end

  def when_show_actions(&block)
    if opts[:show_actions]
      yield if block_given?
    end
  end

  def documents_listing
    employee_record.document_types_groupings.sort_by(&:document_type_name).map do |document_types_grouping|
      document_status = DocumentStatus.new(employee_record, document_types_grouping, employee_record.employee_documents)
      presenter_for(document_status)
    end
  end

  def edit_path
    edit_employee_record_path(employee_record)
  end

  def show_path
    employee_record_path(employee_record)
  end

  def new_document_path(document_type_id = nil)
    new_employee_record_document_path(employee_record, document_type_id: document_type_id)
  end

  def new_employee_note_path
    new_employee_record_employee_note_path(employee_record)
  end

  def assignments_path
    assignments_employee_record_path(employee_record)
  end

  def assigned_tracks_path
    assigned_tracks_employee_record_path(employee_record)
  end

  def suspend_path
    suspend_employee_record_path(employee_record)
  end

  def unsuspend_path
    unsuspend_employee_record_path(employee_record)
  end

  def terminate_path
    terminate_employee_record_path(employee_record)
  end

  def rehire_path
    rehire_employee_record_path(employee_record)
  end

  def new_pto_entry_path
    new_employee_record_pto_entry_path(employee_record)
  end

  def new_time_entry_path
    new_employee_record_time_entry_path(employee_record)
  end

  def new_invite_path
    new_employee_record_invite_path(employee_record)
  end

  def office_show_path
    office_path(employee_record.office)
  end

  def document_group_show_path
    document_group_path(employee_record.document_group)
  end

  def offices_path
    user_offices_path(employee_record.user)
  end

  private

  def default_opts
    {
      show_actions: true
    }
  end
end
