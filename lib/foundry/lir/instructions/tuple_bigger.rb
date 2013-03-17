module Foundry
  class LIR::TupleBiggerInsn < Furnace::SSA::Instruction
    attr_accessor :min_size

    syntax do |s|
      s.operand :tuple#, Type.klass(VI::Tuple)
    end

    def initialize(basic_block, min_size, operands=[], name=nil)
      @min_size = min_size.to_i

      super(basic_block, operands, name)
    end

    def pretty_parameters(p=LIR::PrettyPrinter.new)
      p.text @min_size, ','
    end

    def type
      Type.klass(VI::Object)
    end
  end
end
