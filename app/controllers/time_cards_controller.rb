class TimeCardsController < ApplicationController
  def index
    employee_record = find_employee_record
    authorize employee_record, :list_time_cards?

    begin
      date_range = parse_date_range
    rescue ArgumentError => e
      flash[:error] = e.message
      redirect_to employee_record_time_cards_url(employee_record)
      return
    end

    time_cards = employee_record.time_cards_for(date_range)
    @time_cards_presenter =
      TimeCardsPresenter
      .new(time_cards, current_user)
      .with_context(date_range: date_range, employee_record: employee_record)
  end

  private

  def parse_date_range
    date_from = params[:date_from].presence || 1.week.ago.beginning_of_week.to_s
    date_to = params[:date_to].presence || 1.week.ago.end_of_week.to_s

    Date.parse(date_from).beginning_of_day..Date.parse(date_to).end_of_day
  end

  def find_employee_record
    current_account.employee_records.find(employee_record_id)
  end

  def employee_record_id
    params[:employee_record_id].presence || current_user.employee_record_id
  end
end
