# encoding: UTF-8
module AfPub

GROUP_PARAG_DELIMITOR = "\n\n"

class TextAffinator

TABLE_LIGATURES = {
  'ﬁ'   => 'fi',
  'ﬀ'   => 'ff',
  'ﬃ'   => 'ffi',
  'ﬂ'   => 'fl',
}
keys = TABLE_LIGATURES.keys.join('')
REG_KEYS_LIGATURES = /[#{keys}]/


# --- REG EXPRESSIONS IN TREATMENT ORDER ---

# 'e ' must be treatened before 'e<something>' (no space)


# If the beginning of a line match this regexp, it must be glued to
# the previous paragraph (maybe with a white space, see below).
CAN_NOT_BE_NEW_PARAGRAPH = /^[a-zàâôöñçëéêèîïùûü\)\:\,\+»\.]/.freeze

TRAILING_IS_LOWERCASE = /[a-zàâôöñçëéêèîïùûü]$/.freeze

# If the leading of a line match this regexp, it CAN BE (but
# not sure) a new paragraph. The trailing of the previous line
# can denied this fact.
CAN_BE_NEW_PARAGRAPH = /^[A-ZÂÀÖÔÉÈÊËÎÏÛÙÜ0-9]/.freeze
# If the line ends with these character, next line is not to be
# adding a white space
TRAILING_WITHOUT_SPACE_AFTER = /[\(]$/ 
# If the line is one of these, next line must be glued to it  (with 
# a white space)
ONLY_DETERMINANT = /^(Les|Le|La|Une|Un|Des)$/
# If the line ends with one of these, next line must be glued to
# it (with a white space)
END_WITH_DETERMINANT = /(les|la|le|du|de|,)$/

REG_LISTING = / ?([–\*•])[ \t]([^–\*•]+[,\.])/
REG_LISTING_NUM = / ?([0-9]+[\)\.])[ \t]+(.*?[,\.])/

# Certains character (p.e. la parenthèse ouverte), requiert un autre
# character (p.e. la parenthèse fermante) avant de passer à un autre
# paragraphe.
REG_OPAR_WITHOUT_FPAR   = /\([^\)]*$/
REG_OCHEV_WITHOUT_FCHEV = /«[^»]*$/
REG_OGUIL_WITHOUT_FGUIL = /^[^"]*"[^"]*$/
REG_OCRO_WITHOUT_FCRO   = /\[[^\]]*$/
REG_OACCO_WITHOUT_FACCO = /\{[^\}]*$/
regs = []
[
  ['(',')'],['«','»'],['[',']'],['{','}']
].each do |paire|
  o, f = paire
  regs << "\\#{o}[^\\#{f}]*"
end
regs << '^[^"]*"[^"]*' # special for "
REG_CHARS_WITH_WAITING_CHAR = /(#{regs.join('|')})$/

OPENED_PAIR_NOT_CLOSED = /(«[^»]*|\([^\)]*)$/


REG_END_PARAGRAPH = /[\.\!\?…]$/ # no space after!!!

class << self

  ##
  # Reçoit un texte complet (d'une page) et retourne
  # Le texte "compacté"
  # 
  def affine(texte)
    # paragraphes = texte.split("\n\n").map{|p|compact(p)}
    # puts "\n\n\nparagraphes:\n#{paragraphes}"
    # paragraphes.join(GROUP_PARAG_DELIMITOR).strip
    finalize texte.split("\n\n").map{|p|compact(p)}.join(GROUP_PARAG_DELIMITOR)
  end


  ##
  # @param {String} text, with return carriage
  # @return a list of {String} right paragraphs.
  # 
  # For example :
  #   receive:
  # 
  #       "C'est la 1\nre fois pour\nmoi.",
  # 
  #   return :
  # 
  #       "C'est la 1re fois pour moi."
  #
  #
  # New principle
  # -------------
  #   - tout ce qui ne termine pas par un point final (point, point
  #     d'exclamation, point d'interrogation) ne peut pas être 
  #     considéré comme un paragraphe fini. => la suite doit lui être
  #     collée.
  #   - SAUF si la suite commence par une capitable
  # 
  def compact(text)
    paragraphs = [''] # if the first line starts with '[a-z]'
    
    # 
    # Variables dans l'ordre de précédence.
    # 

    #
    # Quand il faut coller la suite (la ligne suivante) à la
    # ligne courante.
    # (elle est déclarée en premier pour dire qu'elle est précédente
    #  à toutes les autres)
    #
    glue_to_previous = false
    
    # 
    # When next text must be a paragraph start
    # 
    is_new_paragraph = true

    #
    # True if the next text doen't need white space to be glued
    # to the current text.
    #
    no_space_to_line = false

    # 
    # Some 'open' character need to be 'closed'
    # (parenthesis, guillemets, brackets, etc.)
    # 
    waiting_character = nil

    # 
    # Loop on every line (APNode, in fact)
    # 
    # ('reverse' to use 'pop' (faster than 'shift'))
    # 
    reverse_textes = text.split("\n").reverse 
    while (line = reverse_textes.pop)
      
      #@debug
      debug? && debug_line(line)

      # 
      # PRÉ-TREATMENT LINE ANALYSIS
      # ---------------------------
      # Qui va influencer son traitement tout de suite. Par exemple,
      # si la ligne commence par une lettre minuscule, on sait 
      # qu'elle ne peut pas être un nouveau paragraphe, qu'elle doit
      # être collée à la ligne précédente.
      glue_to_previous = glue_to_previous || glue_to_previous?(line)

      #
      # Attention, ça n'est pas la même chose que :
      #  is_new_paragraph = not(glue_to_previous). Ici, on ne met
      # is_new_paragraph à faux que si glue_to_previous est explici-
      # tempent positive.
      # 
      if glue_to_previous
        is_new_paragraph = false
      else
        is_new_paragraph = is_new_paragraph || line.match?(CAN_BE_NEW_PARAGRAPH)
      end

      # 
      # Les raisons qui font qu'on ne doit pas ajouter d'espace 
      # avant la ligne.
      # Note : a pu être déterminé avant.
      if is_new_paragraph
        no_space_to_line = true
      end

      #
      # LINE TREATMENT
      # --------------
      # 

      # 
      # Sauf dans le cas où il ne faille pas ajouter d'espace à la
      # ligne, on lui colle une espace avant
      # 
      line = " #{line}" unless no_space_to_line

      if is_new_paragraph
        paragraphs << line
      else
        paragraphs[-1] << line
      end

      # 
      # POST-TREATMENT ANALYSIS
      # -----------------------
      # On peut faire l'analyse post-traitement qui va influencer
      # le traitement de la ligne suivante.
      # 
      # Bien comprendre que le texte de la variable (p.e. 
      # "is_new_paragraph") concernera la ligne suivante, pas la 
      # ligne courante. Par exemple, si la ligne courante porte la
      # marque d'être une fin de paragraphe indiscutable, la prochai-
      # ne ligne sera un nouveau paragraphe*
      # 
      # (*) Se souvenir que les segments de texte qui se trouvent sur
      # la même ligne ont déjà été rassemblés en une seule ligne.
      # 
      is_new_paragraph = line.match?(REG_END_PARAGRAPH)

      # 
      # Reasons of current line which confirm that next paragraph
      # must be
      glue_to_previous = 
        line.match?(TRAILING_IS_LOWERCASE)  ||
        line.match?(ONLY_DETERMINANT)       || 
        line.match?(END_WITH_DETERMINANT)   ||
        line.match?(OPENED_PAIR_NOT_CLOSED)

      verbose? && glue_to_previous && puts("  -> Le prochain texte doit coller.")
    
      no_space_to_line = line.match?(TRAILING_WITHOUT_SPACE_AFTER)

      #
      # Open chars waiting for close
      # 
      if line.match?(REG_CHARS_WITH_WAITING_CHAR)
        waiting_character = 
          case line
          when REG_OACCO_WITHOUT_FACCO then '}'
          when REG_OPAR_WITHOUT_FPAR   then ')'
          when REG_OGUIL_WITHOUT_FGUIL then '"'
          when REG_OCHEV_WITHOUT_FCHEV then '»'
          when REG_OCRO_WITHOUT_FCRO   then ']'
          end
        waiting_character = /\\#{Regexp.escape(waiting_character)}/
      else
        waiting_character = nil
      end

    end

    #
    # Pull the first added paragraph if it is empty
    # 
    paragraphs.shift if paragraphs.first == ''

    # puts "\n\n\nPARAGRAPHES:\n#{paragraphs.join("\n")}"
      
    #
    # @return all paragraphs as string
    # 
    return paragraphs.join("\n")
  end
  #/compact

  ##
  # @return TRUE si +line+ doit être collée à la ligne précédente
  # 
  def glue_to_previous?(line)
    line.match(CAN_NOT_BE_NEW_PARAGRAPH) || Options.not_paragraph?(line)    
  end

  #@debug
  def debug_line(line)
    puts "--line: #{line.inspect}"
    puts "  CAN_NOT_BE_NEW_PARAGRAPH           : #{line.match?(CAN_NOT_BE_NEW_PARAGRAPH).inspect}"
    puts "  ONLY_DETERMINANT  : #{line.match?(ONLY_DETERMINANT).inspect}"
    puts "  END_WITH_DETERMINANT    : #{line.match?(END_WITH_DETERMINANT).inspect}"
    puts "  OPENED_PAIR_NOT_CLOSED : #{line.match?(OPENED_PAIR_NOT_CLOSED).inspect}"
  end

  ##
  # Receive a {String} text with formating or typographic errors and 
  # @return a well writen text.
  # 
  def finalize(text)

    if debug?
      puts "\n\n\n-> finalize".bleu
      puts "text : #{'<'*40}\n#{text}\n#{'>'*40}"
    end


    text = text.strip
      .gsub(/ +\./,'.')
      .gsub(REG_KEYS_LIGATURES, TABLE_LIGATURES)
      .gsub(REG_LISTING, "\n\\1 \\2")
      .gsub(REG_LISTING_NUM, "\n\\1 \\2")
      .gsub(/ +,/,',') # no spaces before comma
      .gsub(/­(- )?/,'') # cesures
    
    if Options.only_single_spaces?
      text = text
        .gsub(/  +/,' ')
        .gsub(/\t/, ' ')
    end

    if debug?
      puts "\n\n\nAFTER FINALIZE".bleu
      puts "text : #{'<'*40}\n#{text}\n#{'>'*40}"
    end

    return text
  end
  # /finalize


end #/<< self


class MonTestParentheseSeule < MiniTest::Test
  def test_parenthese_seule
    assert("oui (une parenthèse seule".match?(REG_OPAR_WITHOUT_FPAR))
    assert("oui (une parenthèse seule".match?(REG_CHARS_WITH_WAITING_CHAR))
    assert("à la toute fin (".match?(REG_OPAR_WITHOUT_FPAR))
    assert("à la toute fin (".match?(REG_CHARS_WITH_WAITING_CHAR))
    assert("(".match?(REG_OPAR_WITHOUT_FPAR))
    assert("(".match?(REG_CHARS_WITH_WAITING_CHAR))
    refute("non (une parenthèse fermée) pour voir".match?(REG_OPAR_WITHOUT_FPAR))
    refute("non (une parenthèse fermée) pour voir".match?(REG_CHARS_WITH_WAITING_CHAR))
    refute("(juste la parenthèse)".match?(REG_OPAR_WITHOUT_FPAR))
    refute("(juste la parenthèse)".match?(REG_CHARS_WITH_WAITING_CHAR))
    refute("()".match?(REG_OPAR_WITHOUT_FPAR))
    refute("()".match?(REG_CHARS_WITH_WAITING_CHAR))

    assert("oui « le caractère seul".match?(REG_OCHEV_WITHOUT_FCHEV))
    assert("oui « le charactère seul".match?(REG_CHARS_WITH_WAITING_CHAR))
    assert("à la toute fin « ".match?(REG_OCHEV_WITHOUT_FCHEV))
    assert("à la toute fin « ".match?(REG_CHARS_WITH_WAITING_CHAR))
    assert("«".match?(REG_OCHEV_WITHOUT_FCHEV))
    assert("«".match?(REG_CHARS_WITH_WAITING_CHAR))
    refute("non « une parenthèse fermée » pour voir".match?(REG_OCHEV_WITHOUT_FCHEV))
    refute("non « une parenthèse fermée » pour voir".match?(REG_CHARS_WITH_WAITING_CHAR))
    refute("« juste le char »".match?(REG_OCHEV_WITHOUT_FCHEV))
    refute("« juste le char »".match?(REG_CHARS_WITH_WAITING_CHAR))
    refute("«»".match?(REG_OCHEV_WITHOUT_FCHEV))
    refute("«»".match?(REG_CHARS_WITH_WAITING_CHAR))

    assert("oui \"le caractère seul".match?(REG_OGUIL_WITHOUT_FGUIL))
    assert("oui \"le charactère seul".match?(REG_CHARS_WITH_WAITING_CHAR))
    assert("à la toute fin \"".match?(REG_OGUIL_WITHOUT_FGUIL))
    assert("à la toute fin \"".match?(REG_CHARS_WITH_WAITING_CHAR))
    assert("\"".match?(REG_OGUIL_WITHOUT_FGUIL))
    assert("\"".match?(REG_CHARS_WITH_WAITING_CHAR))
    refute("non \"une parenthèse fermée\" pour voir".match?(REG_OGUIL_WITHOUT_FGUIL))
    refute("non \"une parenthèse fermée\" pour voir".match?(REG_CHARS_WITH_WAITING_CHAR))
    refute("\"juste le char\"".match?(REG_OGUIL_WITHOUT_FGUIL))
    refute("\"juste le char\"".match?(REG_CHARS_WITH_WAITING_CHAR))
    refute("\"\"".match?(REG_OGUIL_WITHOUT_FGUIL))
    refute("\"\"".match?(REG_CHARS_WITH_WAITING_CHAR))

    assert("oui [ le caractère seul".match?(REG_OCRO_WITHOUT_FCRO))
    assert("oui [ le charactère seul".match?(REG_CHARS_WITH_WAITING_CHAR))
    assert("à la toute fin [ ".match?(REG_OCRO_WITHOUT_FCRO))
    assert("à la toute fin [ ".match?(REG_CHARS_WITH_WAITING_CHAR))
    assert("[".match?(REG_OCRO_WITHOUT_FCRO))
    assert("[".match?(REG_CHARS_WITH_WAITING_CHAR))
    refute("non [ une parenthèse fermée ] pour voir".match?(REG_OCRO_WITHOUT_FCRO))
    refute("non [ une parenthèse fermée ] pour voir".match?(REG_CHARS_WITH_WAITING_CHAR))
    refute("[ juste le char ]".match?(REG_OCRO_WITHOUT_FCRO))
    refute("[ juste le char ]".match?(REG_CHARS_WITH_WAITING_CHAR))
    refute("[]".match?(REG_OCRO_WITHOUT_FCRO))
    refute("[]".match?(REG_CHARS_WITH_WAITING_CHAR))

    assert("oui { le caractère seul".match?(REG_OACCO_WITHOUT_FACCO))
    assert("oui { le charactère seul".match?(REG_CHARS_WITH_WAITING_CHAR))
    assert("à la toute fin { ".match?(REG_OACCO_WITHOUT_FACCO))
    assert("à la toute fin { ".match?(REG_CHARS_WITH_WAITING_CHAR))
    assert("{".match?(REG_OACCO_WITHOUT_FACCO))
    assert("{".match?(REG_CHARS_WITH_WAITING_CHAR))
    refute("non { une parenthèse fermée } pour voir".match?(REG_OACCO_WITHOUT_FACCO))
    refute("non { une parenthèse fermée } pour voir".match?(REG_CHARS_WITH_WAITING_CHAR))
    refute("{ juste le char }".match?(REG_OACCO_WITHOUT_FACCO))
    refute("{ juste le char }".match?(REG_CHARS_WITH_WAITING_CHAR))
    refute("{}".match?(REG_OACCO_WITHOUT_FACCO))
    refute("{}".match?(REG_CHARS_WITH_WAITING_CHAR))
  end
end

class MonTest < MiniTest::Test
  def test_guil_or_par_end_line
    matches = ['du texte «', 'du texte « V', 'et comme lui (', 'et (si']
    matches.each do |str|
      debug? && puts("#{str.inspect}.match?(#{OPENED_PAIR_NOT_CLOSED}): #{str.match?(OPENED_PAIR_NOT_CLOSED)}")
      assert(str.match?(OPENED_PAIR_NOT_CLOSED))
    end    
    not_matches = ['»', '« le »', '(et)']
    not_matches.each do |str|
      debug? && puts("#{str.inspect}.match?(#{OPENED_PAIR_NOT_CLOSED}): #{str.match?(OPENED_PAIR_NOT_CLOSED)}")
      refute(str.match?(OPENED_PAIR_NOT_CLOSED))
    end
  end
end

test? && MiniTest.run


end #/class TextAffinator
end #/module AfPub
