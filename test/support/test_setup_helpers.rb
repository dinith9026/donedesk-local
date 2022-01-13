module TestSetupHelpers
  def assign_course(employee_record, course)
    create(:assignment, employee_record: employee_record, course: course)
  end

  def build_time_card(employee_record: employee_records(:ed), date: Date.current)
    TimeCard.new(employee_record, date)
  end

  def policy_stub(user = User.new)
    Struct.new(:user).new(user)
  end

  def clock_in(employee_record, occurred_at = Time.zone.now)
    create_time_entry(:clock_in, employee_record, occurred_at)
  end

  def clock_out(employee_record, occurred_at = Time.zone.now)
    create_time_entry(:clock_out, employee_record, occurred_at)
  end

  def start_break(employee_record, occurred_at = Time.zone.now)
    create_time_entry(:start_break, employee_record, occurred_at)
  end

  def end_break(employee_record, occurred_at = Time.zone.now)
    create_time_entry(:end_break, employee_record, occurred_at)
  end

  def create_time_entry(entry_type, employee_record, occurred_at)
    create(
      :time_entry,
      entry_type,
      employee_record: employee_record,
      occurred_at: occurred_at
    )
  end

  def create_document_group_preset(name = 'Default')
    DocumentGroupPreset
      .where(name: name)
      .first_or_create!(
        document_types: [
          { id: document_types(:w4).id, required: true },
          { id: document_types(:agreements).id, required: false },
        ]
    )
  end

  def create_employee_document_group_for(account, name = "Default for Employees")
    groupings = [
      DocumentTypesGrouping.new(document_type: document_types(:w4), required: true),
      DocumentTypesGrouping.new(document_type: document_types(:cpr_certification), required: true),
      DocumentTypesGrouping.new(document_type: document_types(:agreements), required: false),
    ]
    create(:document_group, name: name, account: account, document_types_groupings: groupings, applies_to: 'employees')
  end

  def create_office_document_group_for(account, name = "Default for Offices #{SecureRandom.hex}")
    groupings = [
      DocumentTypesGrouping.new(document_type: document_types(:office_maintenance_checklist), required: false),
    ]
    create(:document_group, name: name, account: account, document_types_groupings: groupings, applies_to: 'offices')
  end

  def count_of_courses_not_in_other_tracks(account, active_track)
    other_tracks = account.tracks.reject { |track| track.id == active_track.id }
    course_ids_for_other_tracks = other_tracks.map { |track| track.courses_tracks.pluck(:course_id) }.flatten
    course_ids_for_track = active_track.courses_tracks.pluck(:course_id)
    course_ids_diff = course_ids_for_track - course_ids_for_other_tracks

    -course_ids_diff.length
  end

  def enable_two_factor!(model)
    model.update!(two_factor_enabled: true)
  end
end
