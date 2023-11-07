writeLines('PATH="C:\\rtools43\\usr\\bin;${PATH}"', con = "~/.Renviron")

Sys.which("make")


install.packages('devtools')
library(usethis)
library(devtools)


setwd("C:/Users/Khadija Oualla/Desktop/M1_SSD/Logiciel Spécialisé R/Package final/ShinyExec")
build()



install.packages("https://raw.githubusercontent.com/OUALLAK/ShinyExec/main/ShinyExec_0.1.0.tar.gz", repos = NULL, type = "source")


library("ShinyExec")
shiny_application()

