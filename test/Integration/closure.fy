# RUN: %foundry_vm   %s -o %t1
# RUN: %foundry_xfrm %t1 -std-xfrms -o %t2
# RUN: %foundry_gen  %t2 | lli | %file_check %s

# CHECK:     [DEBUG: 0x00000000]
# CHECK:     [DEBUG: 0x00000001]
# CHECK:     [DEBUG: 0x00000002]
# CHECK:     [DEBUG: 0x00000003]
# CHECK:     [DEBUG: 0x00000004]
# CHECK:     [DEBUG: 0x0000000a]
# CHECK-NOT: [DEBUG

class Fixed
  def +(other)
    invokeprimitive int_add(self, other)
  end

  def <(other)
    invokeprimitive int_lt(self, other)
  end

  def times(block)
    let mut i = 0u32
    while i < self
      block.call(i)
      i += 1u32
    end
  end
end

class Lambda
  def call(*args, **kwargs)
    invokeprimitive lam_call(self, args, kwargs)
  end
end

def main
  let mut a = 0u32
  5u32.times((x) do
    a += x
    invokeprimitive debug(x)
  end)
  invokeprimitive debug(a)
end
