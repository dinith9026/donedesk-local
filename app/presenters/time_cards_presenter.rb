class TimeCardsPresenter < CollectionPresenter
  DEFAULT_DATE_FORMAT = '%a, %b %-e, %Y'

  def date_from(format = DEFAULT_DATE_FORMAT)
    context&.date_range.begin.to_date.strftime(format)
  end

  def date_to(format = DEFAULT_DATE_FORMAT)
    context&.date_range.end.to_date.strftime(format)
  end

  def time_cards_path
    employee_record_time_cards_path(context.employee_record)
  end
end
