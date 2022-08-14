# encoding: UTF-8
# frozen_string_literal: true

class String

  # Le texte en bleu gras pour le terminal
  def bleu
    "\033[0;96m#{self}\033[0m"
    # 96=bleu clair, 93 = jaune, 94/95=mauve, 92=vert
  end

  def mauve
    "\033[1;94m#{self}\033[0m"
  end

  def orange
    "\033[38;5;214m#{self}\033[0m"
  end
  
  def jaune
    "\033[0;93m#{self}\033[0m"
  end
  alias :yellow :jaune

  def vert
    "\033[0;92m#{self}\033[0m"
  end

  # Le texte en rouge gras pour le terminal
  def rouge
    "\033[0;91m#{self}\033[0m"
  end

  def purple
    "\033[1;34m#{self}\033[0m"
  end

  def yellow
    "\033[1;33m#{self}\033[0m"
  end
  
  def grey
    "\033[1;90m#{self}\033[0m"
  end


end #/String
