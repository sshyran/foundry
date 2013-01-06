module Foundry
  class LIR::CheckArityInsn < Furnace::SSA::Instruction
    attr_accessor :min, :max

    syntax do |s|
      s.operand :arguments
    end

    def initialize(basic_block, min=0, max=0, operands=[], name=nil)
      super(basic_block, operands, name)
      @min, @max = min, max
    end

    def pretty_parameters(p)
      p.text    @min, '..', @max || '.'
      p.keyword 'of'
    end

    def has_side_effects?
      if arguments.nil?
        true
      else
        arguments_ty = arguments.type

        arguments_ty.reified? &&
            !arguments_ty.element_types.count.between?(@min, @max)
      end
    end
  end
end