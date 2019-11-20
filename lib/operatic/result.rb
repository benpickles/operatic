module Operatic
  class Result
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

    def failure!(d = nil)
      set_data(d) if d
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

    def success!(d = nil)
      set_data(d) if d
      @success = true
      freeze
    end

    def success?
      @success
    end

    def to_hash
      @data
    end

    private
      def set_data(d)
        d.each do |key, value|
          @data[key] = value
        end
      end
  end
end
