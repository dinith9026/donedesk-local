class RegisterAccount < ApplicationCommand
  def initialize(form)
    @form = form
  end

  def call
    # Hacky workaround to pass document_group_id presence validation
    @form.office.document_group_id = 'foo'

    return broadcast(:invalid) if @form.invalid?

    transaction do
      create_account
      create_account_owner_user
      group = create_default_document_group_for_offices
      create_office(group)
      create_plan
      create_empty_stats
      create_default_document_group_for_employees
      send_invite_email
    end

    broadcast(:ok, @account)
  end

  private

  def create_account
    attrs = {
      name: @form.name,
      invite_token: SecureRandom.hex,
      time_tracking: @form.time_tracking,
      two_factor_enabled: @form.two_factor_enabled,
    }

    @account = Account.create!(attrs)
  end

  def create_account_owner_user
    attrs = @form.user.attributes.merge(
      password: User.generate_valid_password,
      role: 'account_owner'
    )

    @user = @account.users.create!(attrs)
  end

  def create_office(document_group)
    attrs = @form.office.attributes.merge(document_group_id: document_group.id)

    @office = @account.offices.create!(attrs)
  end

  def create_plan
    attrs = @form.plan.attributes

    @plan = @account.create_plan!(attrs)
  end

  def create_empty_stats
    AccountComplianceStats.create!(
      account_id: @account.id,
      document_compliance_percentage: 0,
      training_compliance_percentage: 0
    )
  end

  def create_default_document_group_for_employees
    preset = DocumentGroupPreset.find_by!(is_default: true, applies_to: 'employees')

    group = @account.document_groups.build(name: preset.name, applies_to: 'employees')
    preset.document_types.each do |document_type|
      group.document_types_groupings.build(
        document_type_id: document_type['id'],
        required: document_type.fetch('required', false)
      )
    end

    group.save!
  end

  def create_default_document_group_for_offices
    preset = DocumentGroupPreset.find_by!(is_default: true, applies_to: 'offices')

    group = @account.document_groups.build(name: preset.name, applies_to: 'offices')
    preset.document_types.each do |document_type|
      group.document_types_groupings.build(
        document_type_id: document_type['id'],
        required: document_type.fetch('required', false)
      )
    end

    group.save!

    group
  end

  def send_invite_email
    AccountsMailer.account_owner_invite(@account).deliver_later
  end
end
