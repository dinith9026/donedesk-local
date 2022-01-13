module EasyI18n
  def from(object, error_name: '', i18n_config: {})
    hint_type(String, error_name)
    hint_type(Hash, i18n_config)
    new(I18n.t("#{name}.#{object.class}.#{error_name}", i18n_config))
  end
end

class DoneDesk::ProgrammingError < StandardError
  extend EasyI18n
end

