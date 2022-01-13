class TrackMailer < ApplicationMailer
  layout 'mailer'

  include ActionView::Helpers::TextHelper

  def employee_assigned_email(employee_record, new_tracks)
    @new_tracks = new_tracks
    @employee_record = employee_record

    mail(
      to: @employee_record.user_email,
      subject: "#{pluralize(@new_tracks.count, 'New Track')} Assigned")
  end

  def courses_added(employee_record, track, new_courses)
    @employee_record = employee_record
    @track = track
    @new_courses = new_courses

    mail(
      to: @employee_record.user_email,
      subject: "#{pluralize(@new_courses.count, 'New Course')} Added to #{@track.name} Track")
  end
end
