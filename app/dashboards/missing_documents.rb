class MissingDocuments
  include Enumerable

  def initialize(employee_records)
    @employee_records = employee_records
    missing_documents
  end

  def each(&block)
    @missing_documents.each do |missing_document|
      yield(missing_document)
    end
  end

  private

  def missing_documents
    @missing_documents ||=
      employees_with_missing_documents.map do |employee_record|
        employee_record.missing_documents.map do |document_type|
          MissingDocument.new(employee_record, document_type)
        end
      end.flatten
  end

  def employees_with_missing_documents
    @employee_records.select do |employee_record|
      employee_record.has_missing_documents?
    end
  end

  class MissingDocument
    attr_reader :employee_record, :document_type

    def initialize(employee_record, document_type)
      @employee_record = employee_record
      @document_type = document_type
    end

    def employee_name
      @employee_record.full_name
    end

    def name
      @document_type.name
    end
  end
end
