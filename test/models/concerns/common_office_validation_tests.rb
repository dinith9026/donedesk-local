module CommonOfficeValidationTests
  extend ActiveSupport::Concern

  included do
    should validate_presence_of(:name)
    should validate_presence_of(:street_address)
    should validate_presence_of(:city)
    should validate_presence_of(:state)
    should validate_presence_of(:zip)
    should validate_presence_of(:phone)
    should validate_presence_of(:time_zone)
    should allow_value('Central Time (US & Canada)').for(:time_zone)
    should_not allow_value('invalid').for(:time_zone)
    should allow_values(*State::STATES.keys).for(:state)
    should_not allow_value('ZZ').for(:state)

    describe 'uniqueness validation' do
      test 'when creating' do
        existing_office = offices(:oceanview_tx)
        subject = @subject.new(
          name: existing_office.name,
          account_id: existing_office.account_id
        )

        assert subject.invalid?
        assert_includes subject.errors[:name], 'already taken'
      end

      test 'when updating' do
        existing_office = offices(:oceanview_tx)
        subject = @subject.new(existing_office.attributes)

        assert subject.valid?
      end
    end
  end
end
