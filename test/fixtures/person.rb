class Person < ActiveRecord::Base
  serialized :name_1, :special_name => proc { |p| "Special #{p.name}" }
  serialized :renamed => :name_2
  
  serialized :not_default => :name_1, :default => false
  
  exclude_from_serialization :lucky_number
  
  def name_1
    "#{name} 1"
  end
  
  def name_2
    "#{name} 2"
  end
end

