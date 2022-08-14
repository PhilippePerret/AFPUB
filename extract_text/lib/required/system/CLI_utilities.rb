# encoding: UTF-8
=begin

  Version 3.8.2

  (cf. l'historique en bas de fichier)

=end
require 'terminal-notifier'
require_relative 'Config'

# Fichier où sont définis les alias, pour pouvoir utiliser la 
# méthode run_alias
RC_FILE_NAME = '.zshrc'

def write_at(str, line, column)
  puts "\e[#{line};#{column}H#{str}"
end

def ecrit(str)
  STDOUT.puts(str)
end

# @return la largeur en colonnes de la console
def console_width
  `tput cols`.strip.to_i
end
alias :console_cols :console_width

# @return la hauteur en nombre de lignes de la console
def console_height
  `tput lines`.strip.to_i
end
alias :console_lines :console_height

def run_alias(alias_cmd)
  @rc_file ||= File.join(Dir.home,RC_FILE_NAME).tap do |pth|
    File.exist?(pth) || raise("Impossible de jouer #{alias_cmd.inspect}. Le fichier contenant les alias est introuvable, il faut définir RC_FILE_NAME dans #{__FILE__}.")
  end
  res = `bash -c ". #{@rc_file}; shopt -s expand_aliases\n#{alias_cmd}" 2>&1`
  return res
end

class Cleaner
  def clear
    puts "\n" # pour certaines méthodes
    puts "\033c"    
  end
  def clear?
    # puts "@requireclear = #{@requireclear.inspect}"
    # puts "verbose? = #{verbose?.inspect} / dont_clear? est #{dont_clear?.inspect}"
    :TRUE == @requireclear ||= true_or_false(not(test?||verbose?||debug?|| self.dont_clear?))
  end
  def dont_clear?
    @dont_clear === true
  end
  def dont_clear(value = true)
    @dont_clear = value
    @requireclear = nil
  end
end
CLEANER = Cleaner.new

# Pour nettoyer la console
def clear
  return if verbose?
  CLEANER.clear? && CLEANER.clear
end

def true_or_false(value)
   value ? :TRUE : :FALSE
end

# True si mode verbeux
def verbose?
  CONFIG.verbose?
end

def debug?
  CONFIG.debug?
end

def cron?
  CONFIG.cron?
end

# True si mode test
def test?
  :TRUE == @ismodetest ||= true_or_false((defined?(MODE_TEST) && MODE_TEST) || ENV['MODE_CLI_TEST'] == "true" || cli?('--test'))
end
alias :tests? :test?


def dont_clear(value = true)
  CLEANER.dont_clear(value)
end


# True si ce sont des tests d'intégration
def test_integration?
  :TRUE == @isintegrationtests ||= true_or_false(ENV['MODE_CLI_TEST'] == "true")
end

##
# Retourne true si la ligne de commande contient exactement +str+
#
def cli?(str)
  case str
  when Regexp
    ARGV.each do |arg|
      if arg.match?(str)
        return arg.match(str).to_a[1]
      end
    end
    return false
  when String
    ARGV.include?(str)
  when Array
    str.each do |opt|
      return true if ARGV.include?(opt)
    end
    return false
  end
end

class AppApi
  def init
    @table = []
  end
  #
  # Utiliser add_api(data) dans le programme pour ajouter ces
  # données au retour api
  def add(data)
    @table << data
  end
  #
  # Utiliser flush_api([data]) dans le programme pour interrompre
  # le programme et sortir ces données.
  # 
  def flush(data = nil)
    if @table.nil?
      puts data.to_json
    else
      @table << data
      puts @table.to_json
    end
    exit 0
  end
end


# True si mode API
# Rappel : en mode API, on écrit dans la page en dernière ligne les 
# données logique au format JSON.
# 
def mode_api?
  :TRUE == @ismodeapi ||= true_or_false(cli?('--api')||cli?('--mode_api'))
end

if mode_api?
  API = AppApi.new
  API.init
end

def ask_or_null(question, params = nil)
  params ||= {}
  response = Q.ask(question.jaune, params)
  response = nil if response && response.upcase == 'NULL'
  return response
end

def add_api(table)
  API.add(table)
end
def flush_api(table = nil)
  API.flush(table)
end

def help?
  cli?('help') || cli?('-h') || cli?('--help') || cli?('--aide') || cli?('aide')
end

alias :console_puts :puts
def puts(msg)
  if debug?
    CONFIG.refdebug.puts(msg)
  else
    console_puts(msg)
  end
end

def less(texte)
  exec "echo \"#{texte.gsub(/\"/,'\\"')}\" | less -r"
end

def path_exists_or_raise(path, what = "fichier", solution = nil)
  unless File.exists?(path)
    log("Le #{what} '#{path}' est inconnu… #{solution||''}\n\n", :rouge, true)
    exit 1
  end
  return path # pour l'utiliser en fin de méthode
end

##
# Pour l'exécution d'une opération dans un bloc, avec un message
# en bleu pendant l'opération puis un message en vert à la fin
# de l'opération.
# @return  {String} Résultat de l'opération
#
def proceed_with_message(msg, &block)
  if CONFIG.cron?
    # --- Par le cron ---
    res = yield
    log(msg)
  else
    # --- hors cron ---
    STDOUT.write "#{msg}…".bleu
    res = yield
    puts "\r#{msg.vert}    "
  end
  return res
end

#
# @param  params {Hash}
#         :title      Le titre
#         :subtitle   Le sous-titre
#         :open       Le fichier/url/dossier à ouvrir
#         :execute    Le code à exécuter
#         :activate   Pour activer une application par son identifiant (p.e. com.apple.safari)
#         :appIcon    L'icone (ça ne fonctionne pas)
#
def notify(msg, params = nil)
  params ||= {}
  TerminalNotifier.notify(msg, params)
end


=begin

HISTORIQUE DES VERSIONS
* 3.8.2
      Suppression de la méthode labelize (doublon avec la 
      classe Tableizor)
* 3.8.1
      Méthode run_alias pour jouer un alias défini dans le
      rc file (~/.zshrc ou autre à définir)
* 3.7.2
      Méthodes console_width et console_height qui retournent
      respectivement la largeur et la hauteur de la console.
* 3.7
      Méthode write_at qui permet d'écrire n'importe où
      en console.
* 3.6
      cli? peut répondre à une expression régulière et renvoyer
      la valeur capturée.
* 3.5
      Ajout de la méthode 'ask_or_null'
* 3.4
      Ajout de la méthode 'less' pour lancer… less.
* 3.3
      Utilisation de terminal-notifier pour gérer les notifications
      de façon beaucoup plus sophistiquée
* 3.2
      Possibilité pour cli? de recevoir une liste de valeur alterna-
      tives à trouver.
* 3.1
      Fonctionne avec le fichier Config.rb (et la class Configuration
      et la constante CONFIG pour avoir les valeurs justes partout,
      quel que soit l'espace de nom)
* 2.5
    - Ajout de la classe Cleaner pour gérer partout l'effacement ou 
      non de la console.
    - La méthode :clear peut s'employer maintenant sans test avant,
      elle gère elle-même le fait qu'il faille ou non effacer la
      console.
* 2.4
    Ajout de dont_clear? et dont_clear()
* 2.3
    Ajout de la méthode #labelize pour construire des tableaux
    avec label <-> colonne
* 2.2
    Ajout de la class AppApi et des méthodes add_api et flush_api

* 2.1
    Ajout de api? pour savoir si on utilise la ligne de commande avec
    l'option --api ou --mode_api qui fait qu'on retourne le résultat
    sous forme de table JSON.

* 1.1
    Toute première version, sans les méthodes de tests test?, verbose?,
    etc.

=end
