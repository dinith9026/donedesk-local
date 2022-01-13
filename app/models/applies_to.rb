class AppliesTo
  def self.valid?(value)
    ['employees', 'offices'].include?(value.to_str)
  end
end
