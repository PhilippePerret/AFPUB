# encoding: UTF-8
module AfPub

class TextAffinator

TABLE_LIGATURES = {
  'ﬁ'   => 'fi',
  'ﬀ'   => 'ff',
  'ﬃ'   => 'ffi',
  'ﬂ'   => 'fl',
}
keys = TABLE_LIGATURES.keys.join('')
REG_KEYS_LIGATURES = /[#{keys}]/


# --- REG EXPRESSIONS ---

REG_ONLY_NUMBER = /^[0-9]+$/

# If the beginning of a line match this regexp, it must be glued to
# the previous paragraph (maybe with a white space, see below).
FIRST_CHAR_CANT_START_NEW_PARAG = /^[a-zàâôöñçëéêèîïùûü\)\:\,\+»\.]/.freeze

TRAILING_IS_LOWERCASE = /[a-zàâôöñçëéêèîïùûü]$/.freeze

# If the leading of a line match this regexp, it CAN BE (but
# not sure) a new paragraph. The trailing of the previous line
# can denied this fact.
CAN_BE_NEW_PARAGRAPH = /^[A-ZÂÀÖÔÉÈÊËÎÏÛÙÜ0-9]/.freeze
# If the line ends with these character, next line is not to be
# adding a white space
TRAILING_WITHOUT_SPACE_AFTER = /[\(]$/ 
# If the line ends with one of these, next line must be glued to
# it (with a white space)
END_WITH_DETERMINANT = /(les|la|le|du|de|,)$/

# Les fins de ligne qui ne peuvent pas être des fins de paragraphe
TRAILING_CANT_BE_ENDING = /[,\(]$/

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
    texte = texte.gsub(/\t/, ' ')
    # puts "\n\n\nTexte avant compactage et finalisation :\n#{texte}\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    # finalize texte.split("\n\n\n").map { |p|compact(p) }.join(GROUP_PARAG_DELIMITOR)
    finalize compact(texte)
    # finalize texte
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
    # La ligne précédente
    # 
    previous_line = nil

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


      is_not_empty_line = not(line.empty?)

      # 
      # PRÉ-TREATMENT LINE ANALYSIS
      # ---------------------------

      # puts "ligne (#{line.empty?.inspect}) = #{line}"

      if line.empty?
        glue_to_previous = false
        is_new_paragraph = true
        no_space_to_line = true
      else
        # Qui va influencer son traitement tout de suite. Par exemple,
        # si la ligne commence par une lettre minuscule, on sait 
        # qu'elle ne peut pas être un nouveau paragraphe, qu'elle doit
        # être collée à la ligne précédente.
        if glue_to_previous === true
          # Rien à faire
        elsif glue_to_previous === false
          # Rien à faire
        elsif is_new_paragraph === true
          glue_to_previous = false
        elsif is_new_paragraph === false
          glue_to_previous = true
        else
          glue_to_previous = glue_to_previous?(line, previous_line)
        end

        no_space_to_line = false

        #
        # Attention, ça n'est pas la même chose que :
        #  is_new_paragraph = not(glue_to_previous). Ici, on ne met
        # is_new_paragraph à faux que si glue_to_previous est explici-
        # tempent positive.
        # 
        if glue_to_previous === true
          is_new_paragraph = false
        else
          is_new_paragraph = is_new_paragraph || line.match?(CAN_BE_NEW_PARAGRAPH)
        end

      end # si la ligne n'est pas vide

      #
      # LINE TREATMENT
      # --------------
      # 

      if is_new_paragraph
        paragraphs << line
      else
        # 
        # Sauf dans le cas où il ne faille pas ajouter d'espace à la
        # ligne, on lui colle une espace avant
        # 
        line = " #{line}" unless no_space_to_line
        # 
        # On colle au précédent paragraphe
        # 
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
      glue_to_previous = nil
      is_new_paragraph = nil

      #
      # On conserve la ligne précédente
      previous_line = line

      # is_new_paragraph = is_not_empty_line && line.match?(REG_END_PARAGRAPH)

      # # Usefull below
      # maybe_title = is_not_empty_line && (line.split(" ").count <= Options.max_word_per_title)
      
      # # 
      # # Reasons of current line which confirm that next paragraph
      # # must be
      # glue_to_previous = 
      #   is_not_empty_line && (
      #     (line.match?(TRAILING_IS_LOWERCASE) && not(maybe_title)) ||
      #     line.match?(END_WITH_DETERMINANT)   ||
      #     line.match?(OPENED_PAIR_NOT_CLOSED)
      #   )

      # # Rédhibitoire pour coller : que la ligne courante soit une
      # # ligne vide.
      # glue_to_previous = false if line == ''

      # verbose? && glue_to_previous && puts("  -> Le prochain texte doit coller.")
    
      # no_space_to_line = is_not_empty_line && line.match?(TRAILING_WITHOUT_SPACE_AFTER)

      # #
      # # Open chars waiting for close
      # # 
      # if is_not_empty_line && line.match?(REG_CHARS_WITH_WAITING_CHAR)
      #   waiting_character = 
      #     case line
      #     when REG_OACCO_WITHOUT_FACCO then '}'
      #     when REG_OPAR_WITHOUT_FPAR   then ')'
      #     when REG_OGUIL_WITHOUT_FGUIL then '"'
      #     when REG_OCHEV_WITHOUT_FCHEV then '»'
      #     when REG_OCRO_WITHOUT_FCRO   then ']'
      #     end
      #   waiting_character = /\\#{Regexp.escape(waiting_character)}/
      # else
      #   waiting_character = nil
      # end

    end

    #
    # Pull the first added paragraph if it is empty
    # 
    paragraphs.shift if paragraphs.first == ''

    # puts "\n\n\nPARAGRAPHES:\n#{paragraphs.join("\n")}"
      
    #
    # @return all paragraphs as string
    # 
    # return paragraphs.join(GROUP_PARAG_DELIMITOR)
    return paragraphs.join("\n")
  end
  #/compact

  ##
  # @return TRUE si +line+ doit être collée à la ligne précédente
  # 
  def glue_to_previous?(line, previous_line)
    return true   if line_can_not_be_paragraph?(line)
    return true   if Options.not_paragraph?(line)
    return true   if line.match?(REG_ONLY_NUMBER)
    return true   if line_wait_for_trailing?(previous_line)
    return false  if line_is_ended_paragraph?(previous_line)
    return false  if line_can_be_paragraph?(line)
  end

  # @return TRUE si la ligne est forcément un paragraphe fini
  def line_is_ended_paragraph?(line)
    line.match?(REG_END_PARAGRAPH)
  end

  # @return TRUE si la ligne +line+ requiert nécessairement une
  # suite. Par exemple si elle se termine par une virgule ou une
  # parenthèse ouverte.
  def line_wait_for_trailing?(line)
    return true if line.match?(TRAILING_CANT_BE_ENDING)
    return true if line.match?(REG_CHARS_WITH_WAITING_CHAR)
    return true if line.match?(OPENED_PAIR_NOT_CLOSED)

    return false
  end

  # @return TRUE si la ligne +line+ ne peut pas être un nouveau
  # paragraphe.
  def line_can_not_be_paragraph?(line)
    line.match?(FIRST_CHAR_CANT_START_NEW_PARAG)     
  end

  def line_can_be_paragraph?(line)
    
  end

  #@debug
  def debug_line(line)
    puts "--line: #{line.inspect}"
    puts "  FIRST_CHAR_CANT_START_NEW_PARAG           : #{line.match?(FIRST_CHAR_CANT_START_NEW_PARAG).inspect}"
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

    text = text.gsub(/\( /, '(')
    text = text.gsub(/ ([\),])/, '\1')

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
