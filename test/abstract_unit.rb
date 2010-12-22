require "test/unit"
require "rubygems"

require "active_record"
require "active_record/fixtures"

require File.dirname(__FILE__) + "/../lib/serialization_extensions"

ActiveRecord::Base.configurations = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.establish_connection(ENV['DB'] || 'mysql')

load(File.dirname(__FILE__) + '/schema.rb')
