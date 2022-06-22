module Operatic
  class Result
    # Generate a subclass of {Result} with named +attrs+ accessors. This
    # wouldn't normally be called directly, see {ClassMethods#result_attr} for
    # example usage.
    #
    # @param attrs [Array<Symbol>] a list of convenience data accessors.
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

    # Read data that's attached to the result.
    def [](key)
      @data[key]
    end

    # Set data on the result.
    def []=(key, value)
      @data[key] = value
    end

    # Mark the result as a failure, optionally attach +data+ via kwargs, and
    # freeze the object so it cannot be modified further.
    #
    # *Note*: Calling {#success!} or {#failure!} more than once will raise a
    # +FrozenError+.
    def failure!(**data)
      set_data(**data)
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

    # Mark the result as a success, optionally attach +data+ via kwargs, and
    # freeze the object so it cannot be modified further.
    #
    # Calling this is not strictly necessary as a +Result+ defaults to being a
    # success, but it's a convenient means of attaching data and of indicating
    # intent in the consuming code.
    #
    # *Note*: Calling {#success!} or {#failure!} more than once will raise a
    # +FrozenError+.
    def success!(**data)
      set_data(**data)
      @success = true
      freeze
    end

    def success?
      @success
    end

    # Returns the full (frozen) hash of data attached to the result via
    # {#success!}, {#failure!}, or convenience accessors added with {.generate}.
    #
    # @return [Hash<Symbol, anything>]
    def to_h
      @data
    end

    private
      def set_data(**data)
        data.each do |key, value|
          @data[key] = value
        end
      end
  end
end
