require File.dirname(__FILE__) + "/abstract_unit"

class SerializationExtensionsItemTest < Test::Unit::TestCase
  fixtures :people
  
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

class SerializationExtensionsTest < Test::Unit::TestCase
  fixtures :people
  
  def test_method_serialization
    assert_equal people(:jonathan).name_1, jonathan_json["name_1"]
  end
  
  def test_method_serialization_with_rename
    assert_equal people(:jonathan).name_2, jonathan_json["renamed"]
  end
  
  def test_proc_serialization
    assert_equal "Special #{people(:jonathan).name}", jonathan_json["special_name"]
  end
  
  def test_non_default_item_excluded
    assert_nil jonathan_json["not_default"]
  end
  
  def test_inclusion_of_non_default_item
    Person.serialization_options = { :items => :not_default }
    assert_not_nil jonathan_json["not_default"]
  end
  
  def test_serialization_options_on_instance
    people(:jonathan).serialization_options = { :except => :name }
    assert_nil jonathan_json["name"]
    assert_equal people(:jonathan).country, jonathan_json["country"]
    
    people(:jonathan).serialization_options = { :only => :name }
    assert_equal people(:jonathan).name, jonathan_json["name"]
    assert_nil jonathan_json["country"]
  end
  
  def test_serialization_options_on_class
    Person.serialization_options = { :only => :renamed }
    assert_equal people(:jonathan).name_2, jonathan_json["renamed"]
    assert_nil jonathan_json["country"]
    
    Person.serialization_options = { :except => :name_1 }
    assert_nil jonathan_json["name_1"]
    assert_equal people(:jonathan).name, jonathan_json["name"]
  end
  
  def test_serialization_options_on_class_with_block
    Person.with_serialization_options :only => :name_1 do
      assert_not_nil jonathan_json["name_1"]
      assert_nil jonathan_json["name"]
    end
    
    assert_not_nil jonathan_json["name"]
  end
  
  def test_serialization_options_without_items
    Person.with_serialization_options :items => false do
      assert_not_nil jonathan_json["name"]
      assert_nil jonathan_json["name_1"]
    end
    
    assert_not_nil jonathan_json["name_1"]
  end
  
  def test_serialization_options_with_all_items
    Person.with_serialization_options :items => :all do
      assert_not_nil jonathan_json["name_1"]
      assert_not_nil jonathan_json["not_default"]
    end
  end
  
  def test_excluded_attributes_not_serialized
    assert_nil jonathan_json["lucky_number"]
  end
  
  def test_specifying_items_also_includes_defaults
    Person.with_serialization_options :items => :name_1 do
      assert_not_nil jonathan_json["name_1"]
      assert_not_nil jonathan_json["renamed"]
      assert_not_nil jonathan_json["special_name"]
    end
  end
  
 private
  def jonathan_json
    JSON.parse(people(:jonathan).to_json)
  end
  
  def teardown
    Person.serialization_options = {}
  end
end

