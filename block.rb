#
class Block
  #
  def initialize(indent, tag)
    @indent = indent
    @tag = tag
  end

  #
  attr_reader :indent

  #
  def open
    return "<#{@tag}>"
  end

  #
  def close
    return "</#{@tag}>"
  end
end
