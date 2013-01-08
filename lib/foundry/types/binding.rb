module Foundry
  class BindingType < LIR::GenericType
    attr_reader :variables, :next

    def initialize(elements, next_)
      # Accept both a Hash or an Array of names.
      @variables = Hash[elements.map { |elem| Array(elem) }]
      @next      = next_
    end

    def to_static_env
      set = [ @variables.keys.to_set ]

      if @next
        set + @next.to_static_env
      else
        set
      end
    end

    def type_at(depth, name)
      if depth > 0
        @next.type_at(depth - 1, name)
      elsif @variables.key? name
        @variables[name]
      else
        raise ArgumentError, "binding for #{name} not found"
      end
    end

    def set_type_at(depth, name, value)
      if depth > 0
        @next.set_type_at(depth - 1, name, value)
      elsif @variables.key? name
        @variables[name] = value
      else
        raise ArgumentError, "binding for #{name} not found"
      end
    end

    def parameters
      [@variables, @next]
    end

    def subtype_of?(other)
      super ||
          other.instance_of?(Monotype) &&
          other.klass == VI::Binding
    end

    def inspect
      types = @variables.map do |name, type|
        "#{name}: #{Furnace::SSA.inspect_type(type)}"
      end

      continuation = ", ..." if @next

      "binding<#{types.join(', ')}#{continuation}>"
    end
  end
end