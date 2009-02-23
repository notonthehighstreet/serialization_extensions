require 'test/unit'

require 'rubygems'
require 'activerecord'

require 'json'
require 'active_record/fixtures'

require File.dirname(__FILE__) + '/../lib/serialization_extensions'
require File.dirname(__FILE__) + '/../lib/serialization_extensions/item'

ActiveRecord::Base.configurations = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.establish_connection(ENV['DB'] || 'mysql')

load(File.dirname(__FILE__) + '/schema.rb')

class Test::Unit::TestCase #:nodoc:
  self.fixture_path = File.dirname(__FILE__) + '/fixtures/'
  
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end

ActiveSupport::Dependencies.load_paths.insert(0, Test::Unit::TestCase.fixture_path)
