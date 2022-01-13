module Kernel
  class InvalidDoneDeskArgumentType < DoneDesk::ProgrammingError; end

  def hint_type(type, argument)
    unless type === argument
      raise InvalidDoneDeskArgumentType.new(I18n.t('DoneDesk::ArgumentError.invalid_type', expected: type, actual: argument.class))
    end

    argument
  end
end
