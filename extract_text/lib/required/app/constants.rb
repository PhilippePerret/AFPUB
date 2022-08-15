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
    bad_file_affixe: "Le fichier '%s' ne correspond pas à l’affixe (%s).\n*** The dossier de l'extraction ne devrait contenir que les .svg provenant du document Affinity Publisher (et tout autre fichier avec une autre extension, bien sûr) ***.",
  }
}

MESSAGES_DATA = {
  'en' => {
    page_out_of_range: 'Page #%i is out ranges.',
    extract_succeeded: "👍 Extraction succeeds!\nThe whole text is in the './%s/%s' file.",
    extract_per_file_succeeded: "👍 Extraction per file succeeds! Each text file has been placed in the './_txt_' folder in the SVGs folder.", 
    folder_contains_svgs: "Folder contains SVG files. OK.",
    all_svgs_are_correct: "All SVG files are correct. OK.",

  },
  'fr' => {
    page_out_of_range: 'La page #%i est en dehors du rang à voir.',
    extract_succeeded: "👍 L'extraction a réussi !\nLe texte complet est dans le fichier './%s/%s'.",
    extract_per_file_succeeded: "👍 L'extraction (par page) a réussi ! Tous les fichiers texte ont été placés dans le dossier './_txt_' du dossier contenant les SVGs des pages.", 
    folder_contains_svgs: "Le dossier courant contient des fichiers SVG. OK.",
    all_svgs_are_correct: "Tous les fichiers SVG sont corrects. OK.",
  }
}
