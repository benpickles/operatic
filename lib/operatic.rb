require 'operatic/errors'
require 'operatic/result'
require 'operatic/version'

module Operatic
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def call(attrs = nil)
      new(attrs)
        .tap(&:call)
        .result
        .freeze
    end

    def call!(attrs = nil)
      call(attrs).tap { |result|
        raise FailureError if result.failure?
      }
    end

    def result(*args)
      @result_class = Result.generate(*args)
    end

    def result_class
      @result_class || Result
    end
  end

  def initialize(attrs = nil)
    attrs.each do |key, value|
      public_send("#{key}=", value)
    end if attrs
  end

  def call
  end

  def failure!(data = nil)
    result.failure!(data)
  end

  def result
    @result ||= self.class.result_class.new
  end

  def success!(data = nil)
    result.success!(data)
  end
end
