# Initialise le processus de création du package R.

# Choix du nom du package et création du dossier correspondant.
nom <- "autoEDA"
usethis::create_package(path = file.path("~", nom))

# Définition des métadonnées du package dans le fichier DESCRIPTION.
desc <- desc::description$new(file.path("~", nom, "DESCRIPTION"))

# Configuration du titre du package dans le fichier DESCRIPTION.
desc$set("Title", "Automated Exploratory Data Analysis")

# Ajout de la description de ce que fait le package.
desc$set("Description", "Ce package fournit des outils pour l'analyse exploratoire de données automatisée.")

# Choix de la licence sous laquelle le package sera publié.
desc$set("License", "MIT + file LICENSE")

# Déclaration de la langue dans laquelle le package est écrit.
desc$set("Language", "fr")

# Sauvegarde des modifications apportées au fichier DESCRIPTION.
desc$write(file = file.path("~", nom, "DESCRIPTION"))

# Développement du package ----------------------------------

# Définissez le répertoire de travail sur le répertoire du package.
setwd(file.path("~", nom))

# Créez un fichier pour une nouvelle fonction.
usethis::use_r("autoSummary")


# Test de la fonction.
usethis::use_test("autoSummary")

# Documenter le package et les fonctions avec Roxygen.
devtools::document()

# Installer le package localement pour l'utiliser.
devtools::install()

# Documenter le package avec un README et des vignettes.

# Créer un README pour expliquer ce que fait le package et comment l'utiliser.
usethis::use_readme_rmd()

# Créer une vignette pour le package.
usethis::use_vignette("autoEDA")

# Construire les vignettes pour inclure dans le package.
devtools::build_vignettes()

# Bonnes pratiques -----------------------------------------

# Créer un fichier de changelog pour suivre les modifications apportées au package.
usethis::use_news_md()

# Gérer les versions du package, en commençant par une version de développement.
usethis::use_version(which = "dev")
