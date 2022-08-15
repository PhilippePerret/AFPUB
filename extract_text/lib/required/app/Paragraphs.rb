# encoding: UTF-8
module AfPub
class Paragraphs

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
REG_START_LINE_NO_NEW_PARAGRAPH = /^[a-zàçéêè\(\)\:\,\+«»\.]/
# If the beginning of a line match this regexp, no white space must
# be added at the end of the previous paragraph.
REG_START_LINE_NO_SPACE = /^(er|re|e|\.|\))( |$)/
# If the line ends with these character, next line is not to be
# adding a white space
REG_END_LINE_NO_SPACE = /[\(]$/ 
# If the line is one of these, next line must be glued to it  (with 
# a white space)
REG_START_LINE_GLUES_NEXT_LINE = /^(Les|Le|La|Une|Un|Des)$/
# If the line ends with one of these, next line must be glued to
# it (with a white space)
REG_END_LINE_GLUES_NEXT_LINE = /(les|la|le|du|de|,)$/

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
# puts "REG_CHARS_WITH_WAITING_CHAR = #{REG_CHARS_WITH_WAITING_CHAR}"

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
# Minitest.run
# exit 0

REG_GUIL_OPEN_NOT_END_PARAGRAPH = /(«[^»]*|\([^\)]*)$/
class MonTest < MiniTest::Test
  def test_guil_or_par_end_line
    matches = ['du texte «', 'du texte « V', 'et comme lui (', 'et (si']
    matches.each do |str|
      debug? && puts("#{str.inspect}.match?(#{REG_GUIL_OPEN_NOT_END_PARAGRAPH}): #{str.match?(REG_GUIL_OPEN_NOT_END_PARAGRAPH)}")
      assert(str.match?(REG_GUIL_OPEN_NOT_END_PARAGRAPH))
    end    
    not_matches = ['»', '« le »', '(et)']
    not_matches.each do |str|
      debug? && puts("#{str.inspect}.match?(#{REG_GUIL_OPEN_NOT_END_PARAGRAPH}): #{str.match?(REG_GUIL_OPEN_NOT_END_PARAGRAPH)}")
      refute(str.match?(REG_GUIL_OPEN_NOT_END_PARAGRAPH))
    end
  end
end

test? && MiniTest.run


REG_END_PARAGRAPH = /[\.\!\?]$/ # no space after!!!

class << self

  ##
  # Receive a list of {String} texts, with paragraphs cutted as in
  # a XML node, and @return a list of {String} right paragraphs.
  # 
  # For example :
  #   receive:
  #     [
  #       "C'est la 1",
  #       "re fois pour"
  #       "moi."
  #     ]
  #   return :
  #     [
  #       "C'est la 1re fois pour moi."
  #     ]
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
  def compact(lines)
    paragraphs = [''] # if the first line starts with '[a-z]'
    glue_next_to_previous = false
    
    # 
    # New principle
    # 
    next_is_new_paragraph = true

    #
    #
    #
    next_line_no_space = false

    deep_debug = false

    # 
    # Loop on every line
    # 
    lines.each do |line|
      puts "--line: #{line.inspect}" #if debug?||verbose?
      if deep_debug
        puts "  (glue_next_to_previous = #{glue_next_to_previous.inspect})"
        puts "  REG_START_LINE_NO_NEW_PARAGRAPH : #{line.match?(REG_START_LINE_NO_NEW_PARAGRAPH).inspect}"
        puts "  REG_START_LINE_NO_SPACE         : #{line.match?(REG_START_LINE_NO_SPACE).inspect}"
        puts "  REG_START_LINE_GLUES_NEXT_LINE  : #{line.match?(REG_START_LINE_GLUES_NEXT_LINE).inspect}"
        puts "  REG_END_LINE_GLUES_NEXT_LINE    : #{line.match?(REG_END_LINE_GLUES_NEXT_LINE).inspect}"
        puts "  REG_GUIL_OPEN_NOT_END_PARAGRAPH : #{line.match?(REG_GUIL_OPEN_NOT_END_PARAGRAPH).inspect}"
      end

      if Options.not_paragraph?(line)
        paragraphs[-1] << ' ' + line
      elsif waiting_character && line.match?(waiting_character)

      elsif next_is_new_paragraph
        paragraphs << line
      elsif line.match?(/^[A-ZÉÀÔ]/) && not(glue_next_to_previous)
        paragraphs << line
      else
        # Which separator ?
        no_space = next_line_no_space || line.match?(REG_START_LINE_NO_SPACE)
        sep = no_space ? '' : ' '
        paragraphs[-1] << sep + line
      end

      # Nouveau principe
      next_is_new_paragraph = line.match?(REG_END_PARAGRAPH)

      glue_next_to_previous = 
        line.match?(REG_START_LINE_GLUES_NEXT_LINE) || 
        line.match?(REG_END_LINE_GLUES_NEXT_LINE) ||
        line.match?(REG_GUIL_OPEN_NOT_END_PARAGRAPH)
      verbose? && glue_next_to_previous && "  -> Le prochain texte doit coller."
    
      next_line_no_space = line.match?(REG_END_LINE_NO_SPACE)

      if line.match?(REG_CHARS_WITH_WAITING_CHAR)
        waiting_character = 
          case line
          when REG_OACCO_WITHOUT_FACCO then '}'
          when REG_OPAR_WITHOUT_FPAR   then ')'
          when REG_OGUIL_WITHOUT_FGUIL then '"'
          when REG_OCHEV_WITHOUT_FCHEV then '»'
          when REG_OCRO_WITHOUT_FCRO   then ']'
          end
        waiting_character = /\\#{waiting_character}/
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
    # @return all paragraphs
    # 
    return paragraphs  
  end
  #/compact


  ##
  # Receive a {String} text with formating or typographic errors and 
  # @return a well writen text.
  # 
  def finalize(text)

    puts "\n\n\n-> finalize".bleu
    puts "text : #{'<'*40}\n#{text}\n#{'>'*40}"

    text = text
      .gsub(/ +\./,'.')
      .gsub(REG_KEYS_LIGATURES, TABLE_LIGATURES)
      .gsub(REG_LISTING, "\n\\1 \\2")
      .gsub(REG_LISTING_NUM, "\n\\1 \\2")
      .gsub(/ +,/,',') # no spaces before comma
    
    if Options.only_single_spaces?
      text = text
        .gsub(/  +/,' ')
        .gsub(/\t/, ' ')
    end


    puts "\n\n\nAFTER FINALIZE".bleu
    puts "text : #{'<'*40}\n#{text}\n#{'>'*40}"

    return text
  end


end #/<< self
end #/class Paragraphs
end #/module AfPub
