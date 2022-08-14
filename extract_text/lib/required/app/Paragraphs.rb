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
REG_START_LINE_NO_NEW_PARAGRAPH = /^[a-zàçéêè\(\)\:\,\+«»\.)]/
# If the beginning of a line match this regexp, no white space must
# be added at the end of the previous paragraph.
REG_START_LINE_NO_SPACE = /^(er|re|e|\.)( |$)/
# If the line is one of these, next line must be glued to it
REG_START_LINE_GLUE_NEXT_LINE = /^(Les|Le|La)$/

END_LINE_NO_RETURN = []

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
  def compact(lines)
    paragraphs = [''] # if the first line starts with '[a-z]'
    glue_to_previous = false
    # 
    # Loop on every line
    # 
    lines.each do |line|
      puts "--line: #{line.inspect}" if debug?
      if glue_to_previous
        paragraphs[-1] << ' ' + line
      elsif line.match(REG_START_LINE_NO_NEW_PARAGRAPH)
        # Which separator ?
        sep = line.match?(REG_START_LINE_NO_SPACE) ? '' : ' '
        paragraphs[-1] << sep + line
      else
        # A very new paragraph
        paragraphs << line
      end
      glue_to_previous = line.match?(REG_START_LINE_GLUE_NEXT_LINE)
    end
    #
    # Pull the first added paragraph if it is empty
    # 
    if paragraphs.first == ''
      paragraphs.shift
    end
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
    text = text
      .gsub(/ +\./,'.')
      .gsub(REG_KEYS_LIGATURES, TABLE_LIGATURES)
    
    return text
  end

end #/<< self
end #/class Paragraphs
end #/module AfPub
