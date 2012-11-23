module Comparable
  def ==(other)
    return true if equal?(other)

    unless comp = (self <=> other)
      return false
    end

    return Comparable.compare_int(comp) == 0
  end

  def >(other)
    unless comp = (self <=> other)
      raise ArgumentError, "comparison of #{self.class} with #{other.class}"
    end

    Comparable.compare_int(comp) > 0
  end

  def >=(other)
    unless comp = (self <=> other)
      raise ArgumentError, "comparison of #{self.class} with #{other.class}"
    end

    Comparable.compare_int(comp) >= 0
  end

  def <(other)
    unless comp = (self <=> other)
      raise ArgumentError, "comparison of #{self.class} with #{other.class}"
    end

    Comparable.compare_int(comp) < 0
  end

  def <=(other)
    unless comp = (self <=> other)
      raise ArgumentError, "comparison of #{self.class} with #{other.class}"
    end

    Comparable.compare_int(comp) <= 0
  end

  def between?(min, max)
    # This could be more elegant, but we need to use <= and => on self to match
    # MRI.
    return false if self < min
    return false if self > max
    return true
  end

=begin no singletons
  # A version of MRI's rb_cmpint (sort of)
  def self.compare_int(int)
    return int if int.kind_of? Integer

    return 1  if int > 0
    return -1 if int < 0
    return 0
  end
=end
end