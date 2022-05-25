require 'operatic/errors'
require 'operatic/result'
require 'operatic/version'

module Operatic
  # @!visibility private
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    # The main way of calling an operation.
    #
    # The class is instantiated with the supplied +attrs+ keyword arguments and
    # calls {Operatic#call} returning a frozen {Result} instance.
    #
    # @return a [Result]
    def call(**attrs)
      new(**attrs)
        .tap(&:call)
        .result
        .freeze
    end

    # Calls {#call} but raises {FailureError} if the returned {Result} is a
    # {Result#failure?} - useful for things like background jobs, rake tasks,
    # test setups, etc.
    #
    # @return [Result]
    def call!(**attrs)
      call(**attrs).tap { |result|
        raise FailureError if result.failure?
      }
    end

    # Define a {Result} subclass with named accessors specific to the class via
    # {Result.generate}.
    #
    # @example
    #   class SayHello
    #     include Operatic
    #
    #     attr_reader :name
    #
    #     result :message
    #
    #     def call
    #       success!(message: "Hello #{name}")
    #     end
    #   end
    #
    #   result = SayHello.call(name: 'Dave')
    #   result.success? # => true
    #   result.message  # => "Hello Dave"
    def result(*args)
      @result_class = Result.generate(*args)
    end

    def result_class
      @result_class || Result
    end
  end

  # An instance of {Result} or a subclass generated by {ClassMethods#result}.
  #
  # @return [Result]
  attr_reader :result

  def initialize(**attrs)
    @result = self.class.result_class.new

    attrs.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  # Override this method with your implementation. Use {#success!} or
  # {#failure!} methods to communicate the {#result}'s status and to attach
  # data it. Define convenience result accessors with {ClassMethods#result}.
  #
  # @example
  #   class SayHello
  #     include Operatic
  #
  #     attr_reader :name
  #
  #     def call
  #       return failure! unless name
  #       success!(message: "Hello #{name}")
  #     end
  #   end
  #
  #   result = SayHello.call(name: 'Dave')
  #   result.success? # => true
  #   result.to_h     # => {:message=>"Hello Dave"}
  #
  #   result = SayHello.call
  #   result.failure? # => true
  #   result.success? # => false
  #   result.to_h     # => {}
  def call
  end

  # Convenience shortcut to the operation's {Result#failure!}.
  def failure!(**data)
    result.failure!(**data)
  end

  # Convenience shortcut to the operation's {Result#success!}.
  def success!(**data)
    result.success!(**data)
  end
end
