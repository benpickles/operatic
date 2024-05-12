module Operatic
  class Result
    # @return [Data]
    attr_reader :data

    # @param data [Data]
    def initialize(data)
      @data = data
    end

    # Convenience proxy to read the +key+ from its {#data} object.
    #
    # @param key [Symbol]
    #
    # @return [anything]
    def [](key)
      data[key]
    end

    # Returns a tuple of self and {#to_h} allowing you to pattern match across
    # both the result's status and its data.
    #
    # @example
    #   class SayHello
    #     include Operatic
    #
    #     def call
    #       data[:message] = 'Hello world'
    #     end
    #   end
    #
    #   case SayHello.call
    #   in [Operatic::Success, { message: }]
    #     # Result is a success, do something with the `message` variable.
    #   in [Operatic::Failure, _]
    #     # Result is a failure, do something else.
    #   end
    #
    # @return [Array(self, Hash<Symbol, anything>)]
    def deconstruct
      [self, to_h]
    end

    # Pattern match against the result's data via {#to_h}.
    #
    # @example
    #   class SayHello
    #     include Operatic
    #
    #     def call
    #       data[:message] = 'Hello world'
    #     end
    #   end
    #
    #   case SayHello.call
    #   in message:
    #     # Result has the `message` key, do something with the variable.
    #   else
    #     # Do something else.
    #   end
    #
    # @return [Hash<Symbol, anything>]
    def deconstruct_keys(keys = nil)
      to_h
    end

    # @return [self]
    def freeze
      data.freeze
      super
    end

    # Forwards unknown methods to its {#data} object allowing convenience
    # accessors defined via {Data.define} to be available directly on the
    # {Result}.
    def method_missing(name, *args, **kwargs, &block)
      return data.public_send(name, *args, **kwargs, &block) if data.respond_to?(name)
      super
    end

    def respond_to?(...)
      super || data.respond_to?(...)
    end

    # Convenience proxy to {Data#to_h}.
    #
    # @return [Hash<Symbol, anything>]
    def to_h
      data.to_h
    end
  end

  class Success < Result
    # @return [false]
    def failure?
      false
    end

    # @return [true]
    def success?
      true
    end
  end

  class Failure < Result
    # @return [true]
    def failure?
      true
    end

    # @return [false]
    def success?
      false
    end
  end
end
