require File.dirname(__FILE__) + "/abstract_unit"

class Person < ActiveRecord::Base
  belongs_to :child, :class_name => "Person"
  
  serialized :name_1, :special_name => proc { |p| "Special #{p.name}" }
  serialized :renamed => :name_2

  exclude_from_serialization :lucky_number

  def name_1
    "#{name} 1"
  end

  def name_2
    "#{name} 2"
  end
  
  def extra_method
    "extra method"
  end
end

class SerializationExtensionsItemTest < ActiveRecord::TestCase
  def test_value_with_symbol_and_string
    item = SerializationExtensions::Item.new(:test, :to_i)
    assert_equal 33, item.value("33")

    item = SerializationExtensions::Item.new(:test, "to_i")
    assert_equal 33, item.value("33")
  end

  def test_value_with_proc
    item = SerializationExtensions::Item.new(:test, proc { |i| i + 1 })
    assert_equal 34, item.value(33)
  end
end

class SerializationExtensionsTest < ActiveRecord::TestCase
  def setup
    @person = Person.new(
      :name => "Jonathan",
      :country => "New Zealand",
      :birthdate => "2004-01-01",
      :lucky_number => 55,
      :child => Person.new(:name => "Child")
    )
  end

  def test_method_serialization
    assert_equal @person.name_1, @person.serializable_hash["name_1"]
  end

  def test_method_serialization_with_rename
    assert_equal @person.name_2, @person.serializable_hash["renamed"]
  end

  def test_proc_serialization
    assert_equal "Special #{@person.name}", @person.serializable_hash["special_name"]
  end

  def test_serialization_options_on_instance
    @person.serialize_with(:except => :name)
    assert_nil @person.serializable_hash["name"]
    assert_equal @person.country, @person.serializable_hash["country"]

    @person.serialize_with(:only => :name)
    assert_equal @person.name, @person.serializable_hash["name"]
    assert_nil @person.serializable_hash["country"]
    
    @person.serialize_with(:methods => :extra_method)
    assert_equal @person.extra_method, @person.serializable_hash[:extra_method]
  end

  def test_excluded_attributes_not_serialized
    assert_nil @person.serializable_hash["lucky_number"]
  end
  
  def test_serialization_options_with_include
    @person.serialize_with(:include => :child)
    assert_not_nil @person.serializable_hash[:child]
  end
end
