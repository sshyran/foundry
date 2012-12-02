class Integer < Numeric
  def to_i
    self
  end

  def +@
    self
  end

  def -@
    0 - self
  end

  def +(other)
    FoundryRt.int_add self, other
  end

  def -(other)
    FoundryRt.int_sub self, other
  end

  def *(other)
    FoundryRt.int_mul self, other
  end

  def /(other)
    FoundryRt.int_div self, other
  end

  def %(other)
    FoundryRt.int_mod self, other
  end

  def <(other)
    FoundryRt.int_lt self, other
  end

  def <=(other)
    FoundryRt.int_lte self, other
  end

  def >(other)
    FoundryRt.int_gt self, other
  end

  def >=(other)
    FoundryRt.int_gte self, other
  end

  def times
    i = 0

    while i < self
      yield i
      i += 1
    end

    self
  end
end