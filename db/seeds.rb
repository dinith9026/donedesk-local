require 'securerandom'

ActiveRecord::Base.transaction do
  puts ''
  puts 'CREATING DOCUMENT TYPES...'
  puts '--------------------------'

  document_types_map = [
    { name: 'Acknowledgement of Receipt of Policy Handbook', required: false},
    { name: 'Agreements', required: false },
    { name: 'Application', required: true },
    { name: 'BLS Certification', required: true },
    { name: 'CPR Certification', required: true },
    { name: 'Candidate Resume', required: true },
    { name: 'CE Training Records', required: true },
    { name: 'Consent for Background Checks', required: true },
    { name: 'Consent for Drug Testing/Search Policy', required: false },
    { name: 'Consent for Video Surveillance', required: false },
    { name: 'Dept. of Labor Notice re Health Insurance Marketplace', required: true },
    { name: 'General Vaccination Records', required: false },
    { name: 'HepB Vaccination Record', required: true },
    { name: 'I-9', required: true },
    { name: 'Notice of Workers\' Compensation Coverage', required: false },
    { name: 'State License', required: true },
    { name: 'W-4', required: true },
  ]

  document_types_map.each do |type_attrs|
    document_type = DocumentType.where(name: type_attrs[:name]).first_or_create!
    puts document_type.name
  end

  puts ''

  puts 'CREATING DEFAULT DOCUMENT GROUP PRESET...'
  puts '--------------------------'

  preset_doc_types = document_types_map.map do |attrs|
    document_type = DocumentType.find_by(name: attrs[:name])

    {
      id: document_type.id,
      required: attrs[:required]
    }
  end
  preset = DocumentGroupPreset.where(name: 'Default')
                              .first_or_create!(document_types: preset_doc_types)
  puts preset.name

  puts ''

  puts 'CREATING SUPER ADMIN...'
  puts '--------------------------'

  # Super Admin
  super_admin_attrs = {
    email: 'cary@dentistsecure.com',
    first_name: 'Cary',
    last_name: 'Smith',
    role: User.roles[:super_admin],
    password: User.generate_valid_password,
  }
  super_admin = User.where(email: super_admin_attrs[:email])
                    .first_or_create!(super_admin_attrs)
  puts "#{super_admin.email} / #{super_admin_attrs[:password]}"

  puts ''
end
