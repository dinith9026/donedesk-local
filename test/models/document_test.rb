require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  should validate_presence_of(:document_type_id)
  should validate_attachment_presence(:file)
  should validate_attachment_size(:file).less_than(5.gigabytes)
  should validate_attachment_content_type(:file)
    .allowing(Document::ALLOWED_FILE_TYPES)
  should allow_value('', ' ', nil).for(:expires_on)
  should_not allow_value(Date.current)
    .for(:expires_on)
    .with_message('must be after today')
    .on(:create)

  describe '#status' do
    test 'when expired' do
      document = Document.new(expires_on: 2.days.ago)

      assert_equal 'Expired', document.status
    end

    test 'when expiring soon' do
      document = Document.new(expires_on: 2.days.from_now)

      assert_equal 'Expiring Soon', document.status
    end

    test 'when not expired or expiring soon' do
      document = Document.new

      assert_equal 'Valid', document.status
    end
  end

  describe '#expirable?' do
    test 'when expiration is not set' do
      document = build(:document, expires_on: nil)

      assert_equal false, document.expirable?
    end

    test 'when expiration is set' do
      document = build(:document, expires_on: Date.tomorrow)

      assert_equal true, document.expirable?
    end
  end

  describe '#expired?' do
    test 'when expiration is not set' do
      document = build(:document, expires_on: nil)

      assert_raises StandardError do
        document.expired?
      end
    end

    test 'when expiration is in the future' do
      document = build(:document, expires_on: Date.tomorrow)

      assert_equal false, document.expired?
    end

    test 'when expiration is in the past' do
      document = build(:document, expires_on: 7.days.ago)

      assert_equal true, document.expired?
    end
  end

  describe '#expiring_soon' do
    test 'when expiration is not set' do
      document = build(:document, expires_on: nil)

      assert_raises StandardError do
        document.expiring_soon?
      end
    end

    test 'when already expired' do
      document = build(:document, expires_on: 7.days.ago)

      assert_equal false, document.expiring_soon?
    end

    test 'when expiration is one day before "soon" threshold' do
      expires_on = (expire_threshold - 1).days.from_now
      document = build(:document, expires_on: expires_on)

      assert_equal true, document.expiring_soon?
    end

    test 'when expiration is day of "soon" threshold' do
      expires_on = expire_threshold.days.from_now
      document = build(:document, expires_on: expires_on)

      assert_equal true, document.expiring_soon?
    end

    test 'when expiration is one day after "soon" threshold' do
      expires_on = (expire_threshold + 1).days.from_now
      document = build(:document, expires_on: expires_on)

      assert_equal false, document.expiring_soon?
    end
  end

  describe 'download_disposition' do
    test 'for pdf' do
      document = build(:document)
      document.stubs(:file_content_type).returns('application/pdf')

      assert_equal 'inline', document.download_disposition
    end

    test 'for image' do
      document = build(:document)
      document.stubs(:file_content_type).returns('image/png')

      assert_equal 'inline', document.download_disposition
    end

    test 'for word document' do
      document = build(:document)
      document.stubs(:file_content_type).returns('application/msword')

      assert_equal 'attachment', document.download_disposition
    end

    test 'for nil content type' do
      document = build(:document)
      document.stubs(:file_content_type).returns(nil)

      assert_equal 'attachment', document.download_disposition
    end

    test 'for blank content type' do
      document = build(:document)
      document.stubs(:file_content_type).returns('')

      assert_equal 'attachment', document.download_disposition
    end
  end

  private

  def expire_threshold
    Document::EXPIRING_SOON_THRESHOLD
  end
end
