class DateMarshaler
  DATE_FORMAT = '%Y-%m-%d'

  def self.dump(date)
    date.is_a?(String) ? date : date.strftime(DATE_FORMAT)
  end

  def self.load(date_string)
    begin
      Date.strptime(date_string, DATE_FORMAT)
    rescue ArgumentError
      raise $!, "Error parsing date value `#{date_string}`: #{$!}", $!.backtrace
    end
  end
end
