#' Lancement d'une Application Shiny
#'
#' Cette fonction permet de lancer l'application Shiny et ouvre un navigateur web avec l'application disponible sur le port 3838 de localhost. Ceci est nécessaire pour le fonctionnement avec Shinyproxy ensuite.
#'
#' @export
#' @examples
#' shiny_application()
shiny_application <- function() {
  appDir <- system.file("ShinyExec_application", package = "ShinyExec")
  shiny::runApp(appDir, host='0.0.0.0', port=3838)
}


