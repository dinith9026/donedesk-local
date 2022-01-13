class PTOEntryPresenter < ModelPresenter
  presents :pto_entry

  delegate :employee_record_full_name, :hours, to: :pto_entry

  def date
    pto_entry.date.strftime('%m/%d/%Y')
  end
end
