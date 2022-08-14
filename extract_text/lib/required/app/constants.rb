# encoding: UTF-8

DEFAULT_LANG = 'en'


ERRORS_DATA = {
  'en' => {
    cant_op:      "I can't operate…", 
    no_svg_files: "No SVG files in that folder!",
    bad_file_affixe: "The '%s' file name doesn't match the document affixe (%s).\n*** The folder should only contains exported SVG files from the Affinity Publisher document ***."
  },
  'fr' => {
    cant_op:      "Je ne peux pas procéder à l'opération…", 
    no_svg_files: "Ce dossier ne contient aucun fichier SVG.",
  }
}

MESSAGES_DATA = {
  'en' => {
    page_out_of_range: 'Page #%i is out ranges.',
    extract_succeeded: "Extraction succeeds!\nThe whole text is in the './%s/%s' file.",
    folder_contains_svgs: "Folder contains SVG files. OK.",
    all_svgs_are_correct: "All SVG files are correct. OK.",

  },
  'fr' => {
    page_out_of_range: 'La page #%i est en dehors du rang à voir.',
    extract_succeeded: "L'extraction a réussi !\nLe texte complet est dans le fichier './%s/%s'.",
    folder_contains_svgs: "Le dossier courant contient des fichiers SVG. OK.",
    all_svgs_are_correct: "Tous les fichiers SVG sont corrects. OK.",
  }
}
