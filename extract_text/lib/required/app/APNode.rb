# encoding: UTF-8

=begin
  class AfPubNode
  ---------------
  Gestion des noeuds text des fichiers SVG exportés.

=end
module AfPub
class APNode

  class << self

    ##
    # @return APNode with +index+ index
    # 
    def get(index)
      @items[index]
    end

    def reset
      @items = []
    end

    def add(apnode)
      @items << apnode
    end

  end #/<< self

  attr_reader :node
  attr_reader :index

  def initialize(node, idx)
    @node   = node
    @index  = idx
    self.class.add(self)
  end

  def x ; @x ||= node['x'][0..-3].to_i end
  def y ; @y ||= node['y'][0..-3].to_i end

  def deltax_with_previous
    @deltax_with_previous ||= begin
      previous && x - previous.x
    end
  end
  def deltay_with_previous
    @deltay_with_previous ||= previous && y - previous.y
  end

  ##
  # @return previous {APNode}
  def previous
    @previous ||= begin
      if self.index == 0
        return nil
      else
        self.class.get(self.index - 1)
      end
    end
  end

  ##
  # @return next {APNode}
  def next
    @next ||= this.class.get(self.index + 1) # can be nil
  end


end #/class APNode
end #/module AfPub
