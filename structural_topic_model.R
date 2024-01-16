library(tidyverse)
library(readr)
library(yaml)

files <- list.files(path = "documents", full.names = TRUE)

meta <- list()
docs <- list()

for (file in files) {
    content <- read_lines(file)
    metadata <- yaml.load(content)
    tags <- metadata$tags

    if ("indigenous" %in% tags) {
        indigenous <- "indigenous"
    } else {
        indigenous <- "non-indigenous"
    }

    document <- paste(content[9:length(content)], collapse = " ")

    tags <- metadata$tags

    meta[[file]] <- indigenous
    docs[[file]] <- document

    print(indigenous)
    #print(document)
}

library(stm)
library(tm)

# Assuming docs is a vector of documents and indigenous is a vector of metadata
# Make sure docs and indigenous are of the same length

# Create a Corpus from the vector of texts
corpus <- Corpus(VectorSource(docs))

# Preprocess the text
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removeWords, stopwords("en"))
corpus <- tm_map(corpus, stripWhitespace)

# Create a Document-Term Matrix
dtm <- DocumentTermMatrix(corpus)

# Convert the DTM to a matrix
word_matrix <- as.matrix(dtm)

# Prepare the metadata
metadata <- as.vector(unlist(meta))
metadata <- as.factor(metadata)

processed <- textProcessor(documents = docs,
                        verbose = TRUE)
out <- prepDocuments(documents = processed$documents,
                    vocab = processed$vocab,
                    meta = meta,
                    verbose = TRUE)

# Create the stm object
documents <- out$documents
vocab <- out$vocab
meta <- as.factor(metadata)
stm_object <- stm(documents, vocab, K = 3, prevalence = ~ meta)

plot(stm_object)
summary(stm_object)

estimateEffect(meta ~ )
