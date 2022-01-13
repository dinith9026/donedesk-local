require_relative './support/test_password_helper'
include TestPasswordHelper

FactoryBot.define do
  factory :contact do
    contact_name { "MyString" }
    contact_address { "MyString" }
    contact_number_1 { "MyString" }
    contact_number_2 { "MyString" }
    contact_file { "MyText" }
    accounts { nil }
  end

  factory :account do
    sequence(:name) { |n| "#{Faker::Company.name} Dental #{n}" }
    invite_token { nil }
    compliance_stats_last_updated_at { Time.current }

    trait :invited do
      invite_token { Clearance::Token.new }
    end

    trait :deactivated do
      deactivated_at { 2.days.ago }
    end

    trait :active do
      deactivated_at { nil }
    end

    after :build do |account|
      account.users << build(:user, :account_owner, account: account)
      document_type = create(:document_type, account: account, applies_to: 'offices')
      document_types_groupings = build(:document_types_grouping, document_type: document_type)
      document_group = create(:document_group, account: account, applies_to: 'offices', document_types_groupings: [document_types_groupings])
      account.offices << build(:office, account: account, document_group: document_group)
      unless account.plan.present?
        account.plan = build(:plan, account: account)
      end
    end
  end

  factory :account_compliance_stats do
    association :account, strategy: :build
    document_compliance_percentage { 100 }
    training_compliance_percentage { 100 }
  end

  factory :assigned_track do
    association :employee_record, strategy: :build
    association :track, strategy: :build
  end

  factory :assignment do
    association :employee_record, strategy: :build
    association :course, strategy: :build

    trait :new do
      after :build do |assignment|
        assignment.exams = []
      end
    end

    trait :passed do
      after :build do |assignment|
        assignment.exams << build(:exam, :passed, created_at: Date.current)
      end
    end

    trait :failed do
      transient do
        with_retakes_remaining { 0 }
      end

      after :build do |assignment, evaluator|
        max_test_retakes = 3
        assignment.course = build(:course, max_test_retakes: max_test_retakes)

        if evaluator.with_retakes_remaining == 0
          exam_count = max_test_retakes
        else
          exam_count = max_test_retakes - 1
        end

        assignment.exams << build_list(:exam, exam_count, :failed, created_at: Date.current)
      end
    end

    trait :expired do
      after :build do |assignment|
        assignment.course = build(:course, :with_question, compliance_expiration_in_days: 90)
        assignment.exams << build(:exam, :passed, created_at: 90.days.ago)
      end
    end

    trait :expiring_soon do
      after :build do |assignment|
        assignment.course = build(:course, compliance_expiration_in_days: 90)
        assignment.exams << build(:exam, :passed, created_at: 61.days.ago)
      end
    end
  end

  factory :certificate do
    passed_on { Date.current }
    expires_on { 1.year.from_now }

    trait :expired do
      expires_on { 1.day.ago }
    end
  end

  factory :chat_terms, class: Hash do
    defaults = {
      accepted_at: Time.now.utc,
      ip_address: Faker::Internet.ip_v4_address
    }

    initialize_with { defaults.merge(attributes) }
  end

  factory :course_track do
    association :course, strategy: :build
    association :track, strategy: :build
  end

  factory :exam do
    passed { true }
    association :assignment, strategy: :build

    trait :passed do
      passed { true }
    end

    trait :failed do
      passed { false }
    end
  end

  factory :document do
    expires_on { 1.year.from_now.midnight }
    summary { Faker::Lorem.sentence }
    file_file_name { 'test.pdf' }
    file_content_type { 'application/pdf' }
    file_file_size { 1024 }
    association :document_type, strategy: :build
  end

  factory :document_type do
    sequence(:name) { |n| "#{Faker::Lorem.word.capitalize} #{n}" }
    applies_to { 'employees' }
  end

  factory :choice do
    sequence(:answer) { |n| "#{Faker::Lorem.word} #{n}" }
    is_correct { false }
    association :question, strategy: :build

    trait :wrong do
      is_correct { false }
    end

    trait :correct do
      is_correct { true }
    end
  end

  factory :course do
    sequence(:title) { |n| "#{Faker::Lorem.sentence.capitalize} #{n}" }
    sequence(:code) { |n| "#{Faker::Lorem.word.upcase} #{n}" }
    description { Faker::Lorem.sentence }
    compliance_expiration_in_days { 'never' }
    max_test_retakes { Faker::Number.number(digits: 1) }
    passing_threshold_percentage { rand 1..100 }
    material_s3_key { 'courses/materials/test_fixture/test.pdf' }
    association :account, strategy: :build
    days_due_within { 30 }
    states { ['TX'] }
    supplements { ["courses/supplements/#{SecureRandom.uuid}/document.pdf"] }

    trait :deactivated do
      deactivated_at { 2.days.ago }
    end

    trait :expiring do
      compliance_expiration_in_days { 90 }
    end

    trait :with_question do
      after :build do |course|
        wrong_choice = build(:choice, :wrong)
        correct_choice = build(:choice, :correct)
        course.questions << build(:question, course: course, choices: [wrong_choice, correct_choice])
      end
    end
  end

  factory :document_group do
    sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
    applies_to { 'employees' }
  end

  factory :document_types_grouping do
    association :document_type, strategy: :build
    association :document_group, strategy: :build
    required { false }
  end

  factory :employee_document do
    association :employee_record, strategy: :build
    association :document, strategy: :build
  end

  factory :employee_note do
    body { Faker::Lorem.sentence }
    association :employee_record, strategy: :build
    association :creator, strategy: :build, factory: :user
  end

  factory :employee_record do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    title { Faker::Job.title }
    employment_type { 'full_time' }
    status { 'employed' }
    dob { Faker::Date.between(from: 65.years.ago, to: 18.years.ago) }
    emergency_contact_name { Faker::Name.name }
    emergency_contact_relationship { ['Father', 'Mother', 'Sister', 'Brother', 'Friend'].sample }
    emergency_contact_email { Faker::Internet.safe_email }
    emergency_contact_phone { Faker::PhoneNumber.phone_number }
    phone { Faker::PhoneNumber.phone_number }
    marital_status { EmployeeRecord.marital_statuses.keys.sample }
    agd_member_number { '478320937' }
    association :office, strategy: :build
    association :user, strategy: :build
    association :document_group, strategy: :build

    trait :full_time do
      employment_type { 'full_time' }
    end

    trait :part_time do
      employment_type { 'part_time' }
    end

    trait :employed do
      status { 'employed' }
    end

    trait :suspended do
      status { 'suspended' }
    end

    trait :terminated do
      status { 'terminated' }
    end
  end

  factory :invite do
    email { Faker::Internet.safe_email }
  end

  factory :library_document do
    name { Faker::Lorem.word }
    summary { Faker::Lorem.sentence(word_count: 1) }
    account

    trait :canned do
      account_id { nil }
    end

    trait :active do
      deactivated_at { nil }
    end

    trait :deactivated do
      deactivated_at { 2.days.ago }
    end
  end

  factory :office do
    sequence(:name) { |n| "#{Faker::Address.street_name} #{n}" }
    street_address { Faker::Address.street_address }
    address2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { Faker::Address.zip }
    phone { Faker::PhoneNumber.phone_number }
    time_zone { 'Central Time (US & Canada)' }
    association :account, strategy: :build
    association :document_group, strategy: :build, applies_to: 'offices'
  end

  factory :offices_user do
    association :office, strategy: :build
    association :user, strategy: :build
  end

  factory :plan do
    monthly_price { Faker::Number.number(digits: 2) }
    max_employees { Faker::Number.between(from: 1, to: 50) }
    association :account, strategy: :build
  end

  factory :pto_entry do
    hours { 8 }
    date { Date.current }
    association :employee_record, strategy: :build
  end

  factory :question do
    id { SecureRandom.uuid }
    text { Faker::Lorem.sentence }
    association :course, strategy: :build

    trait :with_choices do
      after :build do |question|
        question.choices << build(:choice, :wrong)
        question.choices << build(:choice, :correct)
      end
    end
  end

  factory :referral do
    name { Faker::Name.name }
    sequence(:email) { |n| "person#{n}@example.com" }
  end

  factory :time_entry do
    association :employee_record, strategy: :build
    occurred_at { Time.current }
    entry_type { 'clock_in' }

    trait :clock_in do
      entry_type { 'clock_in' }
    end

    trait :clock_out do
      entry_type { 'clock_out' }
    end

    trait :start_break do
      entry_type { 'start_break' }
    end

    trait :end_break do
      entry_type { 'end_break' }
    end
  end

  factory :track do
    sequence(:name) { |n| "Track #{n}" }
    association :account, strategy: :build
  end

  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:email) { |n| "person#{n}@example.com" }
    role { 'employee' }
    password { default_password }
    two_factor_enabled { false }
    association :account, strategy: :build

    trait :super_admin do
      role { 'super_admin' }
    end

    trait :account_owner do
      role { 'account_owner' }
    end

    trait :account_manager do
      role { 'account_manager' }
    end

    trait :employee do
      role { 'employee' }
    end

    trait :with_avatar do
      avatar_file_name { 'photo.jpg' }
      avatar_content_type { 'image/jpg' }
      avatar_file_size { 1024 }
    end
  end
end
