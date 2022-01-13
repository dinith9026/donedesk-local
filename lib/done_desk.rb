module DoneDesk
  require_relative 'done_desk/errors/errors'

  Dir[File.dirname(__FILE__) + '/done_desk/**/*.rb'].sort.each do |file|
    require(file)
  end
end
