# encoding: UTF-8
=begin

Un fichier SVG exporté d'Affinity Publisher peut contenir, à la
racine, soit des texts, soit des groupes de textes (g > text).
Les groupes de textes peuvent être placés dans le flux du fichier à
un autre endroit que sur la page. Par exemple, un pied de page peut
être placé au début du code du fichier SVG, avec une déformation
matricielle qui le replacera.

À l'intérieur d'un groupe <g>, les textes, apparemment, ne doivent 
pas être reclassés. Donc, pour la relève, on met tous les nœuds dans
des groupes qui seront ensuite classés pour que les textes se 
trouvent tous dans le bon ordre au final.

=end
module AfPub
class APNodeGroup

  class << self

    attr_reader :groups

    def add(group)
      @groups ||= []
      @groups << group
    end

  end #/<< self class

  attr_reader :node
  attr_accessor :text_nodes

  def initialize(node)
    @node = node
    @text_nodes = []
    self.class.add(self)
  end

  ##
  # To add a text node {APNode}
  def add_text_node(node)
    @text_nodes << node
  end

  ##
  # @return TRUE if current group is after other +group+
  def after?(group)
    return self.point.after?(group.point)  
  end

  ##
  # Position of the group. Is the position (point) of its first text
  # node.
  def point
    @point ||= begin
      pt = text_nodes.first.point 
      transformation ? pt.deform(matrix) : pt
    end
  end

  def matrix
    @matrix ||= begin
      mtx = transformation.match(/matrix\((.+)\)/).to_a[1].split(',')
      mtx.map do |n|
        n.strip.to_f.round
      end      
    end
  end
  def transformation
    @transformation ||= node && node['transform']
  end


end #/class APNodeGroup
end #/module AfPub
