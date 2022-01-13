class TimeSheetsController < ApplicationController
  def index
    authorize TimeSheet
    time_sheets = TimeSheets.new(employee_records, date_range)
    @time_sheets_presenter =
      TimeSheetsPresenter
      .new(time_sheets, current_user)
      .with_context(date_range: date_range, current_account: current_account)

    respond_to do |format|
      format.html
      format.csv do
        send_data(
          @time_sheets_presenter.to_csv,
          filename: @time_sheets_presenter.csv_filename
        )
      end
    end
  end

  private

  def date_range
    date_from = params[:date_from].presence || 1.week.ago.beginning_of_week.to_s
    date_to = params[:date_to].presence || 1.week.ago.end_of_week.to_s

    Date.parse(date_from).beginning_of_day..Date.parse(date_to).end_of_day
  end

  def find_office
    current_account.offices.tracks_time.find(params[:office_id])
  end

  def employee_records
    records =
      if params[:office_id].present?
        find_office.employee_records
      else
        current_account.employee_records.tracks_time
      end

    records.active.order(:last_name)
  end
end
