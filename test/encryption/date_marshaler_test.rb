require 'test_helper'

class DateMarshalerTest < MiniTest::Test
  def test_dump_with_date
    date = Date.current
    expected = date.strftime(DateMarshaler::DATE_FORMAT)

    result = DateMarshaler.dump(date)

    assert_equal(expected, result)
  end

  def test_dump_with_date_string
    date_string = '1992-09-29'

    result = DateMarshaler.dump(date_string)

    assert_equal(date_string, result)
  end

  def test_load_with_invalid_date_string
    date_string = 'invalid'

    e = assert_raises ArgumentError do
      Date.strptime(date_string, DateMarshaler::DATE_FORMAT)
    end
    assert_includes(e.message, date_string)
  end

  def test_load_with_mmddyyy_format
    date_string = '1992-09-29'
    expected = Date.strptime(date_string, DateMarshaler::DATE_FORMAT)

    result = DateMarshaler.load(date_string)

    assert_equal(expected, result)
  end
end
