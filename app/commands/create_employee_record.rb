class CreateEmployeeRecord < ApplicationCommand
  def initialize(account, form)
    @account = account
    @form = form
  end

  def call
    return broadcast(:invalid) if @form.invalid?

    employee_record =
      transaction do
        existing_user = @form.user_id.present? ? @account.users.find(@form.user_id) : nil

        if existing_user && existing_user.employee_record.blank?
          attrs = @form.attributes.merge(user_id: existing_user.id)

          if @form.document_group_id.blank?
            attrs = attrs.merge(document_group_id: default_document_group.id)
          end

          employee_record = EmployeeRecord.create!(attrs)
          existing_user.update!(
            first_name: employee_record.first_name,
            last_name: employee_record.last_name
          )
          assign_tracks(employee_record) if @form.track_ids.any?
        elsif existing_user && existing_user.employee_record.present?
          # Set the fname/lname so validation fails because of duplicate email
          @form.user.first_name = existing_user.first_name
          @form.user.last_name = existing_user.last_name
          @form.user.valid?
          @form.merge_errors_for(:user)
          return broadcast(:invalid_invite, @form)
        elsif @form.user&.email.present?
          @form.user.first_name = @form.first_name
          @form.user.last_name = @form.last_name

          if @form.user.valid?
            employee_record = EmployeeRecord.create!(@form.attributes)
            assign_tracks(employee_record) if @form.track_ids.any?

            InviteEmployee.call(@account, employee_record, @form.user)

            employee_record
          else
            @form.merge_errors_for(:user)
            return broadcast(:invalid_invite, @form)
          end
        else
          employee_record = EmployeeRecord.create!(@form.attributes)
          assign_tracks(employee_record) if @form.track_ids.any?
        end

        employee_record
      end

    broadcast(:ok, employee_record.id)
  end

  private

  def default_document_group
    @account.document_groups.find_by(name: 'Default') || @account.document_groups.first
  end

  def assign_tracks(employee_record)
    @account.tracks.active.find(@form.track_ids).each do |track|
      employee_record.assigned_tracks.create!(track_id: track.id)

      track.courses.active.each do |course|
        Assignment.find_or_create_by!(employee_record_id: employee_record.id, course_id: course.id)
      end
    end
  end
end
