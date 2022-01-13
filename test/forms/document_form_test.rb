require 'test_helper'

class DocumentFormTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  describe '#expires_on_formatted' do
    test 'when from model (editing)' do
      date = 1.year.from_now.to_s(:db)
      subject = DocumentForm.new(expires_on: date)
      expected = I18n.l(date.to_date, format: :default)

      assert_equal expected, subject.expires_on_formatted
    end

    test 'when from params (creating)' do
      date = '09/13/2018'
      subject = DocumentForm.new(expires_on: date)
      expected = I18n.l(Date.strptime(date, '%m/%d/%Y'), format: :default)

      assert_equal expected, subject.expires_on_formatted
    end
  end

  describe '#cancel_path' do
    test 'when user role is employee' do
      user = build(:user, :employee)
      subject = DocumentForm.new.with_context(user: user)

      assert_equal dashboard_path, subject.cancel_path
    end

    test 'when user role is not employee' do
      user = build(:user, :account_owner)
      subject = DocumentForm.new.with_context(user: user)

      assert_equal documents_path, subject.cancel_path
    end
  end
end
