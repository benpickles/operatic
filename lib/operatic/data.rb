module Operatic
  class Data
    # Generate a subclass of {Data} with named +attrs+ accessors. This wouldn't
    # normally be called directly, see {ClassMethods#data_attr} for example
    # usage.
    #
    # @param attrs [Array<Symbol>] a list of convenience data accessors.
    def self.define(*attrs)
      Class.new(self) do
        attrs.each do |name|
          define_method name do
            self[name]
          end

          define_method "#{name}=" do |value|
            self[name] = value
          end
        end
      end
    end

    # @param kwargs [Hash<Symbol, anything>]
    def initialize(**kwargs)
      @data = kwargs
    end

    # Return the value for +key+.
    #
    # @param key [Symbol]
    #
    # @return [anything]
    def [](key)
      @data[key]
    end

    # Set data on the result.
    #
    # @param key [Symbol]
    # @param value [anything]
    def []=(key, value)
      @data[key] = value
    end

    # @return [self]
    def freeze
      @data.freeze
      super
    end

    # @param hash [Hash<Symbol, anything>]
    #
    # @return [Data]
    def merge(hash)
      self.class.new.tap { |other|
        other.set_data(@data)
        other.set_data(hash)
      }
    end

    # @return [Hash<Symbol, anything>]
    def to_h
      @data
    end

    protected
      def set_data(data)
        data.each do |key, value|
          @data[key] = value
        end
      end
  end
end
