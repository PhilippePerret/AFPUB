# encoding: UTF-8
module AfPub
class ExtractedFile

  def self.show_help
    clear
    if TEXTS_AIDE.key?(Options.lang)
      less(traite( split_texte_by(TEXTS_AIDE[Options.lang], 70)))
    else
      puts "I can't speak “#{Options.lang}“, sorry…".rouge
    end
  end

  def self.traite(str)
    str.gsub(/\{\{(.*)\}\}/) {
      $1.jaune
    }
  end

TEXT_AIDE_FR = <<-TXT

*************************
* AFPUB TEXT EXTRACTION *
*************************

Cet outil permet d'extraire le texte d'un fichier Affinity Publisher (qui ne possède malheureusement pas d'exportation du texte).

PROCÉDURE DE RÉCUPÉRATION D'UN TEXTE
------------------------------------

* Ouvrir le fichier Affinity Publisher,
* exporter toutes les pages au format SVG en haute qualité,
  => (cela produit un dossier contenant tous les fichiers svg)
* ouvrir une fenêtre Terminal à ce dossier,
* [optionnel] jouer la commande {{afpub-extract-text config}} pour créer un fichier de configuration,
* définir la configuration si le fichier config.yaml a été créé le dossier,
* jouer la commande {{afpub-extract-text}}

Dans le dossier des images SVG est alors créé un fichier qui contient le texte. Il est toujours nécessaire de le corriger un peu.

CONFIGURATION
-------------

On peut produire un fichier de configuration permettant d'affiner le traitement à l'aide de la commande {{afpub-extract-text config}} qui doit être jouée dans le Terminal ouvert au dossier des fichiers SVG.

Ce fichier est auto-commenté, mais pour donner un aperçu, on peut définir dans ce fichier si un seul fichier texte doit être produit ou si au contraire chaque page doit faire l'objet d'un fichier, on peut demander d'afficher le numéro de la page dans un export dans un seul fichier. On peut indiquer des caractères dont il faut supprimer les répétitions successives (comme les points dans la table des matières par exemple).

PROBLÈMES CONNUS
----------------

Textes absents
--------------

Si le texte utilise des polices exotiques ou personnelles, il se peut que l'extraction de ces textes échouent quand Publisher doit trans- former ces textes en image (en “path” dans le fichier SVG). Cela peut même arriver avec des polices “officielles”, comme 'Avenir  Next'…
Pour récupérer ces textes :
  * faire une copie du fichier original (pour ne pas le dégrader),
  * ouvrir la duplication du fichier original,
  * si on utilise les feuilles de style, éditer la feuille de styles concernée et utiliser une police simple (Arial), si on n'utilise pas les feuilles de style, sélectionner tout le contenu et appliquer une police simple (Arial),
  * exporter toutes les pages en SVG numérique haute qualité à partir de ce fichier modifié.

TXT

TEXT_AIDE_EN = <<-TXT
*************************
* AFPUB TEXT EXTRACTION *
*************************

This tool allows you to extract text from an Affinity Publisher file (which unfortunately does not have a text export).

TEXT EXTRACTION PROCEDURE
------------------------------------

* Open the Affinity Publisher file,
* export all pages in SVG format in high quality,
  => (this produces a folder containing all the svg files)
* open a Terminal window to this folder,
* [optional] play the {{afpub-extract-text config}} command to create a configuration file,
* set the configuration if the config.yaml file was created in the folder,
* play the command {{afpub-extract-text}}

In the folder of SVG images is then created a file that contains the text. It is always necessary to correct it a little.

CONFIGURATION
-------------

A configuration file can be produced to refine the processing the processing with the command {{afpub-extract-text config}} which must be played in the Terminal opened in the folder of SVG files.

This file is self-commented, but to give an overview, we can define in this file if only one text file should be produced or if on the contrary each page should be the object of a file, one can request to display the page number in an export in a single file. You can indicate characters whose repetition must be removed (such as repetitions (such as the periods in the table of contents, for example). for example).

KNOWN PROBLEMS
----------------

Missing texts
--------------

If the text uses exotic or personal fonts, it is possible that the extraction of these texts may fail when Publisher has to transform these texts into text into an image (as a "path" in the SVG file). This can even happen with "official" fonts, like 'Avenir  Next'...
To recover these texts:
  * make a copy of the original file (not to degrade it),
  * open the duplication of the original file,
  * if you use the style sheets, edit the style sheet concerned and use a simple font and use a simple font (Arial),
    if you don't use the style sheets, select all the content and apply a simple content and apply a simple font (Arial),
  * export all pages in high quality digital SVG from this modified file. from this modified file.

TXT

TEXTS_AIDE = {
  'fr' => TEXT_AIDE_FR,
  'en' => TEXT_AIDE_EN
}
end #/class ExtractedFile
end #/module AfPub
