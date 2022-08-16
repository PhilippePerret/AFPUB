# encoding: UTF-8
module AfPub
class Point
  
  attr_reader :x, :y
  def initialize x, y
    @x = x
    @y = y
  end

  def inspect
    "<<<Point x:#{x} y:#{y}>>>"
  end

  # @return TRUE if current point is "after" +point+
  # "after" means :
  #   - more to the bottom > 70
  #   - more to the right if at same top
  def after?(point)
    if point.y + Y_TOLERANCE < self.y # Y_TOLERANCE <= config
      # 
      # +point+ est plus haut
      # 
      return false
    elsif point.y > self.y + Y_TOLERANCE
      # 
      # +point+ est plus bas
      # 
      return true
    else
      # 
      # +point+ est à la même hauteur (avec la
      # tolérance)
      # 
      return point.x > self.x
    end
  end

  ##
  # Pour obtenir les x et y du point suite à une déformation
  # matricielle.
  # 
  # Pour déformer le point à partir d'une matrice
  # Dans une image SVG, c'est le résultat de transform="matrix(...)"
  # par exemple dans :
  #   <g tranform="matrix(1,0,0,1,300,100)">
  #     <text x="100" y="200">Mon Texte</text>
  #   </g>
  # Pour obtenir les vraies coordonnées du texte qui se trouve dans
  # un "groupe" (g) déformant (transform).
  # 
  # Pour connaitre les vraies coordonnées :
  #   point = Point.new(100,200)
  #   point.deform([1,0,0,1,300,100])
  #   => point possède maintenant ses vrais x e ty
  # 
  # @param matrix {Array} Définition de la déformation à l'aide
  #               des six données a, b, c, d, e, f telles que
  #               définies en css.
  # 
  def deform(matrix)
    a, b, c, d, e, f = matrix
    oldx = x.freeze
    oldy = y.freeze
    @x = a * oldx + c * oldy + e  
    @y = b * oldx + d * oldy + f
    return self
  end
end #/class Point
end #/module AfPub
