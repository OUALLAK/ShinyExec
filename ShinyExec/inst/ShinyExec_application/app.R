# Importation des bibliothèques nécessaires pour le programme
  library(shiny)
library(stats)
library(ggplot2)
library(dplyr)
library(tidyr)
library(readr)
library(readxl)
library(heatmaply)
library(forcats)
library(DT)
library(corrplot)
library(tidyverse)

# Définition de l'interface utilisateur 
ui <- fluidPage(
  # Titre de la page
  titlePanel("Tableau de bord EDA"),
  
  # Mise en page avec une barre latérale et un panneau principal
  sidebarLayout(
    # Contenu de la barre latérale
    sidebarPanel(
      # Entrée pour le téléchargement du fichier
      fileInput("file1", "Choisissez un fichier CSV/Excel/RData",
                accept = c(
                  "text/csv",
                  "text/comma-separated-values,text/plain",
                  ".csv",
                  ".xlsx",
                  ".RData")
      ),
      # Ligne de séparation
      tags$hr(),
      # Affichage dynamique des options pour choisir une variable (sera mis à jour en fonction des données chargées)
      uiOutput("varSelect"),
    ),
    
    # Contenu du panneau principal
    mainPanel(
      # Panneau à onglets pour différentes vues
      tabsetPanel(
        # Premier onglet: Vue d'ensemble des données
        tabPanel("Vue d'ensemble", DTOutput("contents"), tableOutput("dataSummary")),
        # Deuxième onglet: Visualisations
        tabPanel("Visualisation",
                 selectInput("plotType", "Type de visualisation:", 
                             choices = c("Histogramme", "Diagramme en barres", "Boîte à moustaches", "Matrice de corrélation")),
                 uiOutput("varSelectPlot"),
                 plotOutput("dataPlot")
        ),
        # Troisième onglet: Transformation des données
        tabPanel("Transformation", 
                 checkboxInput("normalize", "Normaliser les données?", FALSE),
                 checkboxInput("impute", "Imputer les données manquantes?", FALSE),
                 downloadButton("downloadData", "Télécharger les données transformées"))
      )
    )
  )
)

# Définition du serveur
server <- function(input, output, session) {
  
  # Initialisation d'une valeur réactive pour stocker les données importées
  reactiveData <- reactiveVal()  
  
  # Charger les données en fonction de leur extension
  data_imported <- reactive({
    inFile <- input$file1
    if (is.null(inFile)) {
      return(data.frame())
    }
    
    ext <- tools::file_ext(inFile$datapath)
    
    switch(ext,
           csv = read.csv(inFile$datapath, header = TRUE),
           xlsx = read_excel(inFile$datapath),
           RData = load(inFile$datapath),
           data.frame()
    )
  })
  
  # Mettre à jour les options de sélection de variables chaque fois que de nouvelles données sont chargées
  observe({
    reactiveData(data_imported())
    updateSelectInput(session, "selected_var", 
                      choices = names(reactiveData()), 
                      selected = NULL)
    updateSelectInput(session, "var_select", choices = names(reactiveData()))
    updateSelectInput(session, "var_select2", choices = names(reactiveData()))
  })
  
  # Afficher le choix des variables disponibles
  output$varSelect <- renderUI({
    selectInput("var", "Choisissez une variable:", choices = names(reactiveData()))
  })
  
  # Afficher le contenu des données
  output$contents <- renderDT({
    reactiveData()
  })
  
  # Afficher un tableau réactif des données
  output$dataTable <- renderDT({
    datatable(reactiveData(), options = list(pageLength = 5))
  })
  
  # Afficher un résumé pour une variable sélectionnée
  output$dataSummary <- renderTable({
    req(input$var)
    reactiveData() %>% 
      summarise(
        Mean = mean(get(input$var), na.rm = TRUE),
        Median = median(get(input$var), na.rm = TRUE),
        StdDev = sd(get(input$var), na.rm = TRUE),
        Missing = sum(is.na(get(input$var)))
      )
  })
  
  # Résumé statistique pour la variable sélectionnée
  output$summary <- renderPrint({
    req(reactiveData())
    summary(reactiveData()[, input$selected_var, drop=FALSE])
  })
  
  # Résumé des valeurs manquantes pour la variable sélectionnée
  output$na_summary <- renderPrint({
    req(reactiveData())
    list(
      "Total des observations" = nrow(reactiveData()),
      "Valeurs manquantes" = sum(is.na(reactiveData()[, input$selected_var]))
    )
  })
  
  # Permettre le changement de noms de colonnes
  observeEvent(input$changeNames, {
    if (input$newNames != "") {
      newNames <- unlist(strsplit(input$newNames, ","))
      
      if (length(newNames) == ncol(reactiveData())) {
        currentData <- reactiveData(input$var)
        names(currentData) <- newNames
        reactiveData(currentData)
      }
    }
  })
  
  # Générer des graphiques en fonction du type de visualisation sélectionné et de la variable choisie
  output$dataPlot <- renderPlot({
    req(input$var, reactiveData())
    
    switch(input$plotType,
           "Histogramme" = {
             ggplot(reactiveData(), aes_string(x = input$var)) + 
               geom_histogram(fill = "darkcyan", color = "black", alpha = 0.7) + 
               labs(title = paste("Histogramme de", input$var), x = input$var, y = "Fréquence")
           },
           "Diagramme en barres" = {
             ggplot(reactiveData(), aes_string(x = input$var)) + 
               geom_bar(fill = "darkgreen", color = "black", alpha = 0.7) + 
               labs(title = paste("Diagramme en barres de", input$var), x = input$var, y = "Fréquence")
           },
           # Boîte à moustaches pour visualiser les données
           "Boîte à moustaches" = {
             ggplot(reactiveData(), aes_string(y = input$var)) + 
               geom_boxplot(fill = "darkred", color = "black", alpha = 0.7) + 
               labs(title = paste("Boxplot de", input$var), y = input$var)
           },
           # Matrice de corrélation pour visualiser la corrélation entre les variables numériques
           "Matrice de corrélation" = {
             numeric_data <- reactiveData()[sapply(reactiveData(), is.numeric)]
             corr_matrix <- cor(numeric_data, use = "pairwise.complete.obs")
             corrplot(corr_matrix, method = "circle", type = "upper", tl.col = "darkorange")
           }
    )
  })
  
}

# Lancement de l'application Shiny
shinyApp(ui, server)


