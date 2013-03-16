module Foundry
  class LIR::ConstRefInsn < Furnace::SSA::Instruction
    attr_accessor :constant

    syntax do |s|
      s.operand :cref, Type.klass(VI::Tuple)
    end

    def initialize(basic_block, constant, operands=[], name=nil)
      @constant = constant

      super(basic_block, operands, name)
    end

    def pretty_parameters(p=LIR::PrettyPrinter.new)
      p.text    @constant
      p.keyword 'in'
    end

    def type
      nil
    end
  end
end
