module SerializationExtensions
  def self.included(base)
    base.class_eval do
      class_inheritable_array :serialization_items
      self.serialization_items = []
      
      class_inheritable_array :excluded_from_serialization
      self.excluded_from_serialization = []
      
      # Class-specific serialization options
      cattr_accessor :serialization_options, :instance_writer => false
      self.serialization_options = {}
      
      def serialize_with(options)
        @serialization_options = options
        self
      end
      
      attr_reader :serialization_options
      
      extend ClassMethods
    end
  end
  
  module ClassMethods
    # Define non-attribute data for serialization.
    # 
    #   class Person < ActiveRecord::Base
    #     serialized :extra_name, :age => proc { |p| 100 if p.old? }, :extra_name_with_different_name => :extra_name
    #
    #     def extra_name
    #     end
    #     
    #     def old?
    #       true
    #     end
    #   end
    #
    # The data will then be returned by default when using JSON or XML serialization.
    #
    # Options:
    #   default: include this item by default when serializing (default: true)
    def serialized(*args)
      methods, items = args, args.extract_options!
      methods.each { |m| items[m] = m }
      
      default = items.has_key?(:default) ? items.delete(:default) : true
      
      items.each do |key, value|
        serialization_items << Item.new(key, value, :default => default)
      end
    end
    
    def exclude_from_serialization(*attributes)
      self.excluded_from_serialization.concat(attributes)
    end
    
    def with_serialization_options(options)
      original_options = self.serialization_options
      self.serialization_options = options
      yield
    ensure
      self.serialization_options = original_options
    end
  end
end

module ActiveRecord #:nodoc:
  module Serialization
    class Serializer
      def prepare_serialization_options
        options = @record.class.serialization_options.dup
        options.update(@options)
        options.update(@record.serialization_options) if @record.serialization_options
        
        options[:items] = Array(options[:items]) if options[:items]
        options[:only] = Array(options[:only]) if options[:only]
        options[:except] = Array(options[:except]) if options[:except]
        
        if excluded_attributes = @record.excluded_from_serialization
          options[:except] = Array(options[:except]).concat(excluded_attributes)
        end
        
        @options = options
      end
      
      def process_serialization_extensions(result)
        if items = @record.class.serialization_items
          items.each do |item|
            if include_item?(item)
              result[item.key.to_s] = item.value(@record)
            end
          end
        end
      end
      
      def serializable_record_with_extensions
        prepare_serialization_options
        result = serializable_record_without_extensions
        process_serialization_extensions(result)
        result
      end
      
      alias_method_chain :serializable_record, :extensions
      
     private
      def include_item?(item)
        return false if options[:items] == false
        return true if options[:items] == [:all]
        return true if options[:items] && options[:items].include?(item.key)
        return false if options[:except] && options[:except].include?(item.key)
        return false if options[:only] && !options[:only].include?(item.key)
        item.default?
      end
    end
  end
end

class ActiveRecord::Base
  include SerializationExtensions
end

