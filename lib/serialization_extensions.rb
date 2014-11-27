module SerializationExtensions
  extend ActiveSupport::Concern

  included do
    class_attribute :serialization_items
    self.serialization_items = []

    class_attribute :excluded_from_serialization
    self.excluded_from_serialization = []

    attr_reader :serialization_options

    alias_method_chain :serializable_hash, :extensions
  end

  def serialize_with(options)
    @serialization_options = options
    self
  end

  def serializable_hash_with_extensions(options = nil)
    options = options.try(:clone) || {}

    if serialization_options
      serialization_options.each do |key, value|
        options[key] = Array.wrap(options[key]) + Array.wrap(value)
      end
    end

    # Clear the serialization options since they should not be persisted for the same object
    @serialization_options = nil

    options[:except] = Array.wrap(options[:except]) + self.class.excluded_from_serialization

    result = serializable_hash_without_extensions(options)
    add_serialization_extensions(result, options)
    result
  end

  private

  def add_serialization_extensions(result, options)
    self.class.serialization_items.each do |item|
      if item.included?(options)
        result[item.key.to_s] = item.value(self)
      end
    end

    result
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
    def serialized(*args)
      methods, items = args, args.extract_options!
      methods.each { |m| items[m] = m }

      new_items = []

      items.each do |key, source|
        new_items << Item.new(key.to_s, source)
      end

      self.serialization_items += new_items
    end

    def exclude_from_serialization(*attributes)
      self.excluded_from_serialization += attributes.map(&:to_s)
    end
  end

  class Item < Struct.new(:key, :source)
    def value(object)
      case source
      when Proc
        source.call(object)
      else
        object.send(source)
      end
    end

    def included?(options)
      case
      when options[:except] && options[:except].include?(key)
        false

      when options[:only] && !options[:only].include?(key)
        false

      else
        true
      end
    end
  end
end

class ActiveRecord::Base
  include SerializationExtensions
end
