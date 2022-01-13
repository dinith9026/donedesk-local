class ExpiredDocuments
  include Enumerable

  def initialize(employee_records)
    @employee_records = employee_records
    expired_documents
  end

  def each(&block)
    @expired_documents.each do |expired_document|
      yield(expired_document)
    end
  end

  private

  def expired_documents
    @expired_documents ||=
      employees_with_expired_documents.map do |employee_record|
        employee_record.expired_documents.map do |document|
          ExpiredDocument.new(employee_record, document)
        end
      end.flatten
  end

  def employees_with_expired_documents
    @employee_records.select do |employee_record|
      employee_record.has_expired_documents?
    end
  end

  class ExpiredDocument
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
  end
end
