module ApplicationHelper
  def due_in_or_past_due_x_days(days_until_due)
    return nil if days_until_due.blank?

    days_until_due = days_until_due.to_i

    days_until_due_formatted = pluralize(days_until_due.abs, 'day')

    # For email templates, we're using an inline style instead of a class (text-danger)
    if days_until_due < 0
      content_tag(:span, style: "color: red") do
        "(past due #{days_until_due_formatted})"
      end
    elsif days_until_due == 0
      content_tag(:span, style: "color: red") do
        "(due today)"
      end
    else
      "(due in #{days_until_due_formatted})"
    end
  end

  def due_date(date)
    return nil if date.blank?

    date = date.to_date

    date_formatted = I18n.localize(date, format: :default)

    if date < Date.current
      content_tag(:span, date_formatted, class: "text-danger")
    else
      date_formatted
    end
  end

  def file_exts_from_mime_types(mime_types)
    require 'rack/mime'
    mime_types.map do | mime_type|
      Rack::Mime::MIME_TYPES.invert[mime_type]
    end.uniq
  end

  def valid_date?(date_string)
    match = /^\d{1,2}\/\d{1,2}\/\d{4}$/.match(date_string)
    m, d, y = date_string.split '/'

    match.present? && Date.valid_date?(y.to_i, m.to_i, d.to_i)
  end

  def document_type_display_name(document_type)
    (document_type.name + (document_type.is_confidential ? ' <i class="icon-lock"></i>' : '')).html_safe
  end

  def keep_alive_interval_in_milliseconds
    (Rails.configuration.session_expiration_in_minutes - 5) * 60000
  end

  def user_avatar_url(user)
    url =
      if user && user.avatar.present?
        user.avatar.expiring_url(10, :medium)
      elsif user
        user.gravatar_url(300)
      else
        User.new.gravatar_url(300)
      end

    url.html_safe
  end

  def when_user_tracks_time(user, &block)
    yield if user.tracks_time?
  end

  def time_card_presenter
    TimeCardPresenter.new(todays_time_card, policy(todays_time_card))
  end

  def when_user_can(action, policy, &block)
    if policy.public_send("#{action}?")
      yield
    end
  end

  def account_names(accounts)
    accounts.map(&:name)
  end

  def bootstrap_class_for(flash_type)
    { 'success' => 'alert-success',
      'error'   => 'alert-danger',
      'alert'   => 'alert-warning',
      'notice'  => 'alert-info'
    }.fetch(flash_type, "alert-#{flash_type.to_s}")
  end

  def nav_link(current_path, link_text, link_path, menu_type, icon_type = nil)
    is_active = current_path == link_path

    active_class = is_active ? 'active' : nil

    sub_nav_content = capture(&block) if block_given?

    maybe_icon = icon_type ? "<i class=\"icon icon-#{icon_type}\"></i>" : ''

    content_tag(:li, class: "nav-item #{active_class}") do
      concat link_to(link_path) {
        <<-HTML.strip.html_safe
          #{maybe_icon}<span class="#{menu_type}">#{link_text}</span>
        HTML
      }
      concat sub_nav_content
    end
  end

  def sub_nav_link(current_path, link_text, link_path)
    content_tag(:ul, class: 'menu-content') do
      content_tag(:li) do
        link_to link_text, link_path
      end
    end
  end

  def tag_class_for_employee_status(status)
    {
      'terminated' => 'tag-danger',
      'suspended'  => 'tag-warning',
      'employed'   => 'tag-success',
    }.fetch(status, 'tag-grey')
  end

  def us_states
    State.options_for_select
  end

  private

  def todays_time_card
    TimeCard.new(current_user&.employee_record, Date.current)
  end
end
