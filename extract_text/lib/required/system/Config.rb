# encoding: UTF-8
# frozen_string_literal: true
=begin

  Utiliser CONFIG.<methode>

=end

class Configuration

  # true si option --noop
  def noop?
    :TRUE == @isnoop ||= true_or_false(cli?('--noop'))
  end

  # true si option -v/--verbose
  def verbose?
    :TRUE == @isverbose ||= true_or_false(cli?('-v')||cli?('--verbose'))
  end

  # true si option -l/--loop
  def loop?
    :TRUE == @isloop ||= true_or_false(cli?('-l')||cli?('--loop'))
  end

  # true si option -d/--debug
  def debug?
    :TRUE == @isdebug ||= true_or_false(cli?('--debug')||cli?('-d'))
  end

  # Utiliser CONFIG.debug = true/false pour le changer à la volée
  def debug=(value)
    @isdebug = value ? :TRUE : :FALSE
  end

  # Pour rediriger la sortie de :puts vers le fichier './output'
  def refdebug
    @refdebug ||= begin
      pth = File.join(__dir__,'..','..','output')
      File.delete(pth) if File.exist?(pth)
      console_puts "\n\nATTENTION : La sortie standard est redirigée vers le fichier './output'".jaune
      sleep 0.5
      File.open(pth,'a')
    end
  end

  # true si option -q/--quiet
  def quiet?
    :TRUE == @isquiet ||= true_or_false(cli?('-q')||cli?('--quiet'))
  end

  #
  # @return TRUE si la commande est appelée depuis le cron, 
  # c'est-à-dire avec l'option '--cron' ou '-c'
  def cron?
    :TRUE == @iscron ||= true_or_false(cli?('--cron'))
  end

  def cli?(str)
    ARGV.include?(str)
  end

  def reset
    @iscron     = nil
    @isquiet    = nil
    @refdebug   = nil
    @isdebug    = nil
    @isnoop     = nil
    @isverbose  = nil
    @isloop     = nil
  end

end

CONFIG = Configuration.new
