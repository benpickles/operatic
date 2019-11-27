module Operatic
  class Result
    # Generate a subclass of {Result} with named +attrs+ accessors. This
    # wouldn't normally be called directly, see {ClassMethods#result} for
    # example usage.
    #
    # @param attrs [Array<Symbol>] a list of accessors to the result's data.
    def self.generate(*attrs)
      Class.new(self) do
        attrs.each do |name|
          define_method name do
            @data[name]
          end

          define_method "#{name}=" do |value|
            @data[name] = value
          end
        end
      end
    end

    def initialize
      @data = {}
      @success = true
    end

    # Mark the result as a failure, optionally attach data, and freeze the
    # object so it cannot be modified further.
    #
    # *Note*: After calling this method calling {#success!} or {#failure!}
    # again will raise a +FrozenError+.
    #
    # @param data [Hash<Symbol, anything>] an optional hash of data to attach
    #   to the result.
    def failure!(data = nil)
      set_data(data) if data
      @success = false
      freeze
    end

    def failure?
      !@success
    end

    def freeze
      @data.freeze
      super
    end

    # Mark the result as a success, optionally attach data, and freeze the
    # object so it cannot be modified further.
    #
    # Calling this is not strictly necessary as a result defaults to being a
    # success, but it's a convenient means of attaching data and of indicating
    # intent in the consuming code.
    #
    # *Note*: After calling this method calling {#success!} or {#failure!}
    # again will raise a +FrozenError+.
    #
    # @param data [Hash<Symbol, anything>] an optional hash of data to attach
    #   to the result.
    def success!(data = nil)
      set_data(data) if data
      @success = true
      freeze
    end

    def success?
      @success
    end

    # Returns the full (frozen) hash of data attached to the result via
    # {#success!}, {#failure!}, or convenience accessors added with {.generate}.
    #
    # @return [Hash]
    def to_h
      @data
    end

    private
      def set_data(data)
        data.each do |key, value|
          @data[key] = value
        end
      end
  end
end
