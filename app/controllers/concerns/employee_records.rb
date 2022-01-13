module EmployeeRecords
  extend ActiveSupport::Concern

  def search_and_filter(employee_records)
    if params[:search]
      employee_records =
        employee_records
        .where("first_name ILIKE ? OR last_name ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    elsif request.format.html?
      if params[:status].nil? || params[:status] == 'employed'
        employee_records = employee_records.employed
      elsif params[:status] == 'suspended'
        employee_records = employee_records.suspended
      elsif params[:status] == 'terminated'
        employee_records = employee_records.terminated
      end
    end

    employee_records
  end
end
