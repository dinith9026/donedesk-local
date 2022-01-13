module Acceptance
  module PageHelpers
    def navigate_to(nav_trail)
      within '.main-menu' do
        items = nav_trail.split('>').map(&:strip)
        click_on items[0]
        sleep 0.5
        click_on items[1]
      end
    end

    def time_cards_table_id
      '#time-cards-table'
    end

    def click_on_time_card_link(date)
      click_on date.strftime('%a, %b %-e, %Y')
    end

    def fill_in_and_submit_date_range_filter_form(from, to)
      format = '%m/%d/%Y'

      within '#date-filter-form' do
        fill_in 'date_from', with: from.strftime(format)
        fill_in 'date_to', with: to.strftime(format)
        click_on 'Go'
      end
    end
  end
end
