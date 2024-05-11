require 'operatic/data'
require 'operatic/errors'
require 'operatic/result'
require 'operatic/version'

module Operatic
  # @!visibility private
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    # The main way to call an operation. This initializes the class with the
    # supplied +attrs+ keyword arguments and calls {Operatic#call} returning a
    # frozen {Result} instance.
    #
    # @param attrs [Hash<Symbol, anything>]
    #
    # @return [Failure, Success]
    def call(**attrs)
      operation = new(**attrs)
      operation.call
      operation.result || Success.new(operation.data).freeze
    end

    # The same as {#call} but raises {FailureError} if the returned {#result} is
    # a {Failure} - useful for things like background jobs, rake tasks, test
    # setups, etc.
    #
    # @param attrs [Hash<Symbol, anything>]
    #
    # @return [Success]
    #
    # @raise [FailureError] if the operation is not a {Success}
    def call!(**attrs)
      call(**attrs).tap { |result|
        raise FailureError if result.failure?
      }
    end

    # Define a class-specific {Data} subclass with the named accessors added via
    # {Data.define}.
    #
    # @example
    #   class SayHello
    #     include Operatic
    #
    #     data_attr :message
    #
    #     def call
    #       success!(message: "Hello #{@name}")
    #     end
    #   end
    #
    #   result = SayHello.call(name: 'Dave')
    #   result.class     # => Operatic::Success
    #   result.message   # => "Hello Dave"
    #   result[:message] # => "Hello Dave"
    #   result.to_h      # => {:message=>"Hello Dave"}
    #
    # @param attrs [Array<Symbol>] a list of convenience data accessors to
    #   define on the {Result}.
    def data_attr(*attrs)
      @data_class = Data.define(*attrs)
    end

    # @return [Class<Data>]
    def data_class
      @data_class || Data
    end
  end

  # @return [Success, Failure]
  attr_reader :result

  # @param attrs [Hash<Symbol, anything>]
  def initialize(**attrs)
    attrs.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  # Override this method with your implementation. Use {#success!}/{#failure!}
  # to define the status of the result {Success}/{Failure} and attach data.
  #
  # @example
  #   class SayHello
  #     include Operatic
  #
  #     def call
  #       return failure! unless @name
  #       success!(message: "Hello #{@name}")
  #     end
  #   end
  #
  #   result = SayHello.call(name: 'Dave')
  #   result.class     # => Operatic::Success
  #   result.failure?  # => false
  #   result.success?  # => true
  #   result[:message] # => "Hello Dave"
  #   result.to_h      # => {:message=>"Hello Dave"}
  #
  #   result = SayHello.call
  #   result.class     # => Operatic::Failure
  #   result.failure?  # => true
  #   result.success?  # => false
  #   result.to_h      # => {}
  def call
  end

  # Any data to be communicated via the operation's result should be added to
  # this {Data} object.
  #
  # *Note*: This will be frozen when returned from an operation.
  #
  # @example
  #   class SayHello
  #     include Operatic
  #
  #     def call
  #       data[:message] = "Hello #{@name}"
  #     end
  #   end
  #
  #   result = SayHello.call(name: 'Dave')
  #   result.data.to_h     # => {:message=>"Dave"}
  #   result.data.frozen?  # => true
  #
  # @return [Data]
  def data
    @data ||= self.class.data_class.new
  end

  # Mark the operation as a failure and prevent further modification to the
  # operation, its result, and its data.
  #
  # @param kwargs [Hash<Symbol, anything>]
  #
  # @raise [FrozenError] if called more than once
  def failure!(**kwargs)
    @result = Failure.new(data.merge(kwargs))
    freeze
  end

  # @return [self]
  def freeze
    @result.freeze
    super
  end

  # Mark the operation as a success and prevent further modification to the
  # operation, its result, and its data.
  #
  # @param kwargs [Hash<Symbol, anything>]
  #
  # @raise [FrozenError] if called more than once
  def success!(**kwargs)
    @result = Success.new(data.merge(kwargs))
    freeze
  end
end
