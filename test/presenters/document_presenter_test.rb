require 'test_helper'

class DocumentPresenterTest < ActiveSupport::TestCase
  subject { DocumentPresenter.new(nil, nil) }
  should delegate_method(:id).to(:document)
  should delegate_method(:summary).to(:document)
  should delegate_method(:file_name).to(:document)
  should delegate_method(:employee_record_full_name).to(:document)
  should delegate_method(:employee_record).to(:document)

  describe '#expiration' do
    test 'when expirable and expired' do
      document_stub =
        Struct
        .new(:expirable?, :expired?, :expires_on)
        .new(true, true, Date.current)
      subject = DocumentPresenter.new(document_stub, nil)
      expected = "<span class=\"text-danger\">expired on #{subject.expires_on}</span>"

      assert_equal expected, subject.expiration
    end

    test 'when expirable and NOT expired' do
      document_stub =
        Struct
        .new(:expirable?, :expired?, :expires_on)
        .new(true, false, Date.current)
      subject = DocumentPresenter.new(document_stub, nil)

      assert_equal "expires on #{subject.expires_on}", subject.expiration
    end

    test 'when not expirable' do
      document_stub = Struct.new(:expirable?).new(false)
      subject = DocumentPresenter.new(document_stub, nil)

      assert_equal "no expiration", subject.expiration
    end
  end

  describe '#expires_on' do
    test 'when not expirable' do
      document_stub = Struct.new(:expirable?).new(false)
      subject = DocumentPresenter.new(document_stub, nil)

      assert_empty subject.expires_on
    end

    test 'when present' do
      document = documents(:oceanview_ed_w4)
      document.expires_on = 30.days.ago
      subject = DocumentPresenter.new(document, nil)
      expected = I18n.localize(document.expires_on.to_date, format: :default)

      assert_equal expected, subject.expires_on
    end
  end

  test '#created_at' do
    document = documents(:oceanview_ed_w4)
    subject = DocumentPresenter.new(document, nil)
    expected = I18n.localize(document.created_at.to_date, format: :default)

    assert_equal expected, subject.created_at
  end

  test 'paths' do
    document = documents(:oceanview_ed_w4)
    subject = DocumentPresenter.new(document, policy_stub).with_context(belongs_to: employee_documents(:oceanview_ed_w4))

    refute_nil subject.download_path
  end
end
