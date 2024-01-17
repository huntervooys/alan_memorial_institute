library(lubridate)
library(dplyr)
library(purrr)
library(yaml)
library(stm)
library(tidytext)

set.seed(0055)

files <- list.files("documents", pattern = "*.txt", full.names = TRUE)

process_file <- function(file) {
  content <- readLines(file)
  content <- gsub("@", "_", content)
  fm <- yaml::yaml.load(content[1:8])

  indigenous <- if ("indigenous" %in% fm$tags) {"indigenous"} else {"non-indigenous"}
  corporate <- if ("news, corporate" %in% fm$tags) {"corporate"} else {"non-corporate"}
  student <- if ("news, student" %in% fm$tags) {"student"} else {"non-student"}

  date <- mdy(fm$date)

  publisher <- fm$publisher

  if (length(content) >= 10) {
    sentences <- content[10:length(content)]
    data.frame(
      date = rep(date, length(sentences)),
      indigenous = rep(indigenous, length(sentences)),
      corporate = rep(corporate, length(sentences)),
      student = rep(student, length(sentences)),
      publisher = rep(publisher, length(sentences)),
      sentence = sentences
    )
  } else {
    NULL
  }
}

meta <- map_dfr(files, process_file)

meta$date <- as.numeric(meta$date)
meta$publisher <- tolower(meta$publisher)
meta <- meta |>
  filter(!is.na(date))

meta |>
  count(indigenous)

meta |>
  count(corporate)

meta |>
  count(student)

meta |>
  count(publisher)

meta$indigenous <- factor(meta$indigenous)
meta$corporate <- factor(meta$corporate)
meta$student <- factor(meta$student)
meta$publisher <- factor(meta$publisher)

temp <- textProcessor(documents = meta$sentence,
              metadata = meta,
              lowercase = TRUE,
              removenumbers = TRUE,
              removepunctuation = TRUE,
              removestopwords = TRUE,
              language = "en")
docs <- temp$documents
vocab <- temp$vocab
meta <- temp$meta

temp <- prepDocuments(documents = docs,
                     vocab = vocab,
                     meta = meta,
                     verbose = TRUE) ## lower and upper thresh not set

docs <- temp$documents
meta <- temp$meta
vocab <- temp$vocab


K <- seq(3,15,1)
kresult <- searchK(documents = docs,
                   vocab = vocab, K,
                   prevalence= ~ s(date) + indigenous + corporate + student,
                   data=meta)
plot(kresult)

## picking k = 9
K <- 9
mod.out <- selectModel(docs, vocab, K, prevalence = ~ date + indigenous + corporate + student, data = meta, runs = 25)
plotModels(mod.out)
model <- mod.out$runout[[1]]


estimate <- estimateEffect(formula = 1:K ~ date + indigenous + corporate + student,
               stmobj = model,
               metadata = meta,
               documents = docs) |>
  tidy() |>
  filter(term != "(Intercept)")

## time
## topic 4 gets more common over time
  ## about dogs searching for odor on the group, detecting, reporting
  ## thoughts are about dog teams (all three)
## topic 8 gets more common over time
  ## agreement, SQI, panel, court, excavation
  ## all about settlement agreement
## topic 9 gets less common over time
  ## indigenous land, the pope, children, experiments
  ## thoughts are about the past - lana ponting, Doctrine of Discovery, quebec nationalism
## topic 5 gets more common over time
  ## security guard, attack, assault, security firm
  ## about the attack from the security guard
estimate |>
  filter(term == "date")

summary(model)
findThoughts(model, texts = meta$sentence, topics = c(4,8,9,5), n = 3, meta = meta)
labelTopics(model, topics = c(4,8,9,5), n = 5)
cloud(model, topic = 8, type = "model")
cloud(model, topic = 8, type = "documents", documents = docs)

estimate <- estimateEffect(formula = 1:K ~ s(date) + indigenous + corporate + student,
                           stmobj = model,
                           metadata = meta,
                           documents = docs)

plot(estimate,
     covariate = "date",
     model = model,
     topics = c(4,8,9,5),
     method = c("continuous"))

plot(estimate, model,
     covariate = "indigenous",
     method = c("pointestimate"), ci.level = 0.95)

as.factor(meta$indigenous)

## topics in indigenous documents
plot(estimate,
     covariate = "indigenous",
     model = model,
     method = c("difference"),
     cov.value1 = "indigenous",
     cov.value2 = "non-indigenous",
     ci.level = 0.90,
     printlegend = T,
     verbose.labels = F,
     main = "topics in indigenous compared to non-indigenous documents")

# topics in corporate documents
plot(estimate,
     covariate = "corporate",
     model = seven_mod,
     topics = c(1,2,3,4,5,6,7),
     method = c("difference"),
     cov.value1 = "corporate",
     cov.value2 = "non-corporate",
     ci.level = 0.90,
     printlegend = T,
     verbose.labels = F,
     main = "topics 4,1,7 (corporate compared to non-corporate documents)")


## picking k = 5
K <- 5
model <- stm(documents = docs, vocab = vocab, K = K, prevalence = ~ s(date) + indigenous + corporate + student, data = meta)

estimate <- estimateEffect(formula = 1:K ~ s(date) + indigenous + corporate + student,
                           stmobj = model,
                           metadata = meta,
                           documents = docs) |>
  tidy() |>
  filter(term != "(Intercept)")

## time
# 1
## surges at s(date)8
## much less likely in indigenous documents
## human remain detection
# 2
## date 2 a lot, date 3 a lot less; date 6 a lot
# procedure
# 3
## more likely to appear in student documents
## seurity guard
# 4
## down at 2, surge at 3 and 4
## much higher in indigenous and corporate, much lower in student
## colonization, territory, pope, cross
# 5
## low at 3 and 4, and 5, but increasing
## less common in corporate
# thoughts: all about MK Ultra
estimate |>
  filter(p.value <= 0.01)

ts <- seq(1,5)

summary(model)
findThoughts(model, texts = meta$sentence, topics = ts, n = 3, meta = meta)
labelTopics(model, topics = ts, n = 10)
cloud(model, topic = 8, type = "model")
cloud(model, topic = 8, type = "documents", documents = docs)

estimate <- estimateEffect(formula = 1:K ~ s(date) + indigenous + corporate + student,
                           stmobj = model,
                           metadata = meta,
                           documents = docs)

plot(estimate)

plot(estimate,
     covariate = "date",
     model = model,
     topics = ts,
     method = c("continuous"))

plot(estimate, model,
     covariate = "indigenous",
     method = c("difference"), ci.level = 0.95,
     cov.value1 = "indigenous",
     cov.value2 = "non-indigenous",
     main = "indigenous vs non-indigenous; less likely in indigenous to left",
     verbose.labels = F)

plot(estimate, model,
     covariate = "corporate",
     method = c("difference"), ci.level = 0.95,
     cov.value1 = "corporate",
     cov.value2 = "non-corporate",
     verbose.labels = F,
     main = "corporate vs non-corporate")

plot(estimate, model,
     covariate = "student",
     method = c("difference"), ci.level = 0.95,
     cov.value1 = "student",
     cov.value2 = "non-student",
     main = "student vs non-student",
     verbose.labels = F)
