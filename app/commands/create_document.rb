class CreateDocument < ApplicationCommand
  def initialize(form, employee_record)
    @form = form
    @employee_record = employee_record
  end

  def call
    return broadcast(:invalid) if @form.invalid?

    transaction do
      document = Document.create!(@form.attributes)
      EmployeeDocument.create!(employee_record: @employee_record, document: document)
    end

    broadcast(:ok, @employee_record.id)
  end
end
