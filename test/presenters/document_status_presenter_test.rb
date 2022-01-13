require 'test_helper'

class DocumentStatusPresenterTest < ActiveSupport::TestCase
  describe '#status_class' do
    test 'when document is present and valid' do
      document = build(:document)
      document.stubs(:status).returns('Valid')
      grouping = build(:document_types_grouping, required: true)
      document_status = DocumentStatus.new(belongs_to_stub, grouping, [document])
      subject = DocumentStatusPresenter.new(document_status, nil)

      assert_equal 'text-bold-700', subject.status_class
    end

    test 'when document is not present and document type is optional' do
      grouping = build(:document_types_grouping, required: false)
      document_status = DocumentStatus.new(belongs_to_stub, grouping, [])
      subject = DocumentStatusPresenter.new(document_status, nil)

      assert_equal 'text-muted', subject.status_class
    end
  end

  describe '#status_color_class' do
    test 'when document is expiring soon' do
      document = build(:document, expires_on: 3.days.from_now)
      grouping = build(:document_types_grouping)
      document_status = DocumentStatus.new(belongs_to_stub, grouping, [document])
      subject = DocumentStatusPresenter.new(document_status, nil)

      assert_equal 'warning', subject.status_color_class
    end

    test 'when document is expired' do
      document = build(:document, expires_on: 3.days.ago)
      grouping = build(:document_types_grouping)
      document_status = DocumentStatus.new(belongs_to_stub, grouping, [document])
      subject = DocumentStatusPresenter.new(document_status, nil)

      assert_equal 'danger', subject.status_color_class
    end

    test 'when document is not expired or expiring soon' do
      document = build(:document)
      grouping = build(:document_types_grouping)
      document_status = DocumentStatus.new(belongs_to_stub, grouping, [document])
      subject = DocumentStatusPresenter.new(document_status, nil)

      assert_equal 'primary', subject.status_color_class
    end

    test 'when document type is required and document is missing' do
      grouping = build(:document_types_grouping, required: true)
      document_status = DocumentStatus.new(belongs_to_stub, grouping, [])
      subject = DocumentStatusPresenter.new(document_status, nil)

      assert_equal 'grey', subject.status_color_class
    end
  end

  describe '#icon_type' do
    test 'when document is present and valid' do
      document = build(:document)
      grouping = build(:document_types_grouping)
      document_status = DocumentStatus.new(belongs_to_stub, grouping, [document])
      subject = DocumentStatusPresenter.new(document_status, nil)

      assert_equal 'check', subject.icon_type
    end

    test 'when document is not present and document type is optional' do
      grouping = build(:document_types_grouping, required: false)
      document_status = DocumentStatus.new(belongs_to_stub, grouping, [])
      subject = DocumentStatusPresenter.new(document_status, nil)

      assert_equal 'blank', subject.icon_type
    end

    test 'when document is not valid and required' do
      grouping = build(:document_types_grouping, required: true)
      document_status = DocumentStatus.new(belongs_to_stub, grouping, [])
      subject = DocumentStatusPresenter.new(document_status, nil)

      assert_equal 'flag', subject.icon_type
    end
  end

  describe '#status' do
    test 'when document is present' do
      document = build(:document)
      document.stubs(:status).returns('foo')
      grouping = build(:document_types_grouping)
      document_status = DocumentStatus.new(belongs_to_stub, grouping, [document])
      subject = DocumentStatusPresenter.new(document_status, nil)

      assert_equal 'foo', subject.status
    end

    test 'when document is not present but is required' do
      grouping = build(:document_types_grouping, required: true)
      document_status = DocumentStatus.new(belongs_to_stub, grouping, [])
      subject = DocumentStatusPresenter.new(document_status, nil)

      assert_equal 'Required/Missing', subject.status
    end

    test 'when document is not present but is optional' do
      grouping = build(:document_types_grouping, required: false)
      document_status = DocumentStatus.new(belongs_to_stub, grouping, [])
      subject = DocumentStatusPresenter.new(document_status, nil)

      assert_equal 'Optional', subject.status
    end
  end

  private

  def belongs_to_stub
    Object.new
  end
end
