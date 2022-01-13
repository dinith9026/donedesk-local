class ExpiringDocuments
  include Enumerable

  def initialize(employee_records)
    @employee_records = employee_records
    expiring_documents
  end

  def each(&block)
    @expiring_documents.each do |expiring_document|
      yield(expiring_document)
    end
  end

  private

  def expiring_documents
    @expiring_documents ||=
      employees_with_expiring_documents.map do |employee_record|
        employee_record.documents_expiring_soon.map do |document|
          ExpiringDocument.new(employee_record, document)
        end
      end.flatten
  end

  def employees_with_expiring_documents
    @employee_records.select do |employee_record|
      employee_record.has_documents_expiring_soon?
    end
  end

  class ExpiringDocument
    attr_reader :employee_record, :document

    def initialize(employee_record, document)
      @employee_record = employee_record
      @document = document
    end

    def employee_name
      @employee_record.full_name
    end

    def name
      @document.name
    end

    def expires_in
      @document.expires_in
    end
  end
end
