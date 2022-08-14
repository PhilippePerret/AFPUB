# encoding: UTF-8

=begin
  class AfPubNode
  ---------------
  Gestion des noeuds text des fichiers SVG exportés.

=end
module AfPub
class APNode

  class << self

    attr_reader :items
    
    ##
    # @return APNode with +index+ index
    # 
    def get(index)
      @items[index]
    end

    def eachNode(&block)
      if block_given?
        @items.each { |node| yield node }
      end
    end

    ##
    # Insert a node at a place and reset index of each instance
    #
    def insert_at(node, idx)
      @items.insert(idx, node)
      update_indexes
    end

    def update_indexes
      @items.each_with_index do |node, idx| 
        node.index = idx
      end
    end

    ##
    # Remove and @return APNode at +idx+
    # 
    def APNode.delete_at(idx)
      @items.delete_at(idx)
    end

    def reset
      @items = []
    end

    def add(apnode)
      @items << apnode
    end

  end #/<< self

  attr_reader :svgfile
  attr_reader :node
  attr_accessor :index

  def initialize(svgfile, node, idx)
    @svgfile = svgfile
    @node   = node
    @index  = idx
    self.class.add(self)
  end

  def inspect
    "<<<APNode ##{index} '#{text}' (x:#{x}, y:#{y})>>>"
  end

  def x ; @x ||= node['x'][0..-3].to_i end
  def y ; @y ||= node['y'][0..-3].to_i end
  def text ; @text ||= node.text end


  def far_from_previous?
    if previous && deltay_with_previous.abs > 100
      if deltay_with_previous > 0
        # <= previous highter 
        # => ok
        return false
      else
        # <= previous is lower (> 100)
        if deltax_with_previous > svgfile.options[:column_width]
          # <= text is on the right column
          # => ok
          return false
        else
          # <= previous is lower and current is not on right column
          # => search new place for current
          return true
        end
      end
    else
      # <= no previous
      # => no problemo
      return false
    end
  end

  def deltax_with_previous
    previous && x - previous.x
  end
  def deltay_with_previous
    previous && y - previous.y
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
