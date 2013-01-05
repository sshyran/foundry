module Foundry
  class LIR::LvarLoadInsn < Furnace::SSA::GenericInstruction
    attr_accessor :depth
    attr_accessor :variable

    syntax do |s|
      s.operand :binding, VI::Binding
    end

    def initialize(basic_block, type, depth, variable, operands=[], name=nil)
      super(basic_block, type, operands, name)
      @depth, @variable = depth, variable
    end

    def pretty_parameters(p)
      p.text    @variable.inspect
      p.keyword 'at'
      p.text    @depth
      p.keyword 'in'
    end
  end
end