module SerializationExtensions
  class Item
    attr_reader :key
    
    def initialize(key, value, options = {})
      options.assert_valid_keys :default
      
      @key, @value, @options = key, value, options
    end
    
    def value(object)
      case @value
        when Symbol, String
          object.send(@value)
        when Proc
          @value.call(object)
      end
    end
    
    def default?
      @options[:default]
    end
  end
end

