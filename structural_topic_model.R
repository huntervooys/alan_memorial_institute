library(tidyverse)

files <- list.files(path = "documents", full.names = TRUE)

data <- list()

for (file in files) {
    content <- readLines(file)

    yaml_start <- which(content == "---")
    yaml_end <- which(content == "...")
    content <- content[(yaml_start+1):(yaml_end-1)]

    metadata <- yaml::yaml.load(paste(content, collapse = "\n"))

    data[[file]] <- metadata
}