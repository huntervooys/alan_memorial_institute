library(tidyverse)
library(yaml)
library(stm)
library(tidytext)

set.seed(1234)

#### reading files (mostly boring shit)
files <- list.files(path = "documents", full.names = TRUE)
grave_site_df = data.frame(row.names = c("indigenous", "corporate", "student", "document"))
for (file in files) {
    content <- read_lines(file)
    yaml_data <- yaml.load(content)
    tags <- yaml_data$tags
    ## coding indigenous variable
    if ("indigenous" %in% tags) {
        indigenous <- "indigenous"
    } else {
        indigenous <- "non-indigenous"
    }
    ## coding corporate variable
    if ("news, corporate" %in% tags){
      corporate <- "corporate"
    } else {
      corporate <- "non-corporate"
    }
    ## codingn student varaible
    if ("news, student" %in% tags) {
      student <- "student"
    } else {
      student <- "non-student"
    }
    document <- paste(content[9:length(content)], collapse = " ")
    grave_site_df <- rbind(grave_site_df, data.frame(indigenous, corporate, student, document))
    #print(indigenous)
    #print(corporate)
    #print(student)
    #print(document)
}
rm(yaml_data, content, document, file, files, indigenous, tags, corporate, student)


temp <- textProcessor(documents = grave_site_df$document,
                      metadata = grave_site_df,
                      lowercase = TRUE,
                      removenumbers = TRUE,
                      removepunctuation = TRUE,
                      removestopwords = TRUE,
                      language = "en")
meta <- temp$meta
vocab <- temp$vocab
docs <- temp$documents
out <- prepDocuments(documents = docs,
                     vocab = vocab,
                     meta = meta,
                     lower.thresh = 3,
                     upper.thresh = 20,
                     verbose = TRUE)
docs <- out$documents
vocab <- out$vocab
meta <- out$meta
rm(temp, out)

#stm_obj <- stm(docs, vocab, 7, prevalence = ~indigenous+corporate+student, data = meta, verbose = TRUE)
#summary(stm_obj)
#plot(stm_obj)
#glance(stm_obj)
#tidy(stm_obj)

#estimate <- estimateEffect(formula = 1:7~indigenous+corporate+student, stmobj= stm_obj, metadata = meta, uncertainty = c("Global"))

#summary(estimate)
#plot.estimateEffect(estimate, "indigenous", stm_obj, method="pointestimate", ci.level = 0.9)

K <- c(3:15)
kresult <- searchK(documents = docs,
                   vocab = vocab, K,
                   prevalence=~indigenous+corporate+student,
                   data=meta)
plot(kresult)

# I selected k = 7 or k = 11 based on diagnostic values
##### k = 7, model 4 is best (arbitrary)
seven_mod.out <- selectModel(docs, vocab, 7, prevalence = ~ indigenous + corporate + student, data = meta, verbose = TRUE, runs = 25)
plotModels(seven_mod.out)
seven_mod <- seven_mod.out$runout[[4]]
##### k = 11, model 5 is best (arbitary)
eleven_mod.out <- selectModel(docs, vocab, 11, prevalence = ~ indigenous + corporate + student, data = meta, verbose = TRUE, runs = 25)
plotModels(eleven_mod.out)
eleven_mod <- eleven_mod.out$runout[[5]]

## getting rid of things to pick k and model 6 (grave_site_df is same as meta)
rm(K, kresult, grave_site_df, seven_mod.out, eleven_mod.out)

##### for k=7 topics
summary(seven_mod)
plot(seven_mod)
estimateEffect(formula = 1:7~indigenous+corporate+student,
               stmobj= seven_mod,
               metadata = meta,
               documents = docs,
               uncertainty = c("Global"),
               nsims = 25) |>
  tidy() |>
  filter(term != "(Intercept)", p.value <= 0.05)

estimateEffect(formula = 1:7~indigenous+corporate+student,
               stmobj= seven_mod,
               metadata = meta,
               documents = docs,
               uncertainty = c("Local"),
               nsims = 25) |>
  tidy() |>
  filter(term != "(Intercept)", p.value <= 0.05)

estimateEffect(formula = 1:7~indigenous+corporate+student,
               stmobj= seven_mod,
               metadata = meta,
               documents = docs,
               uncertainty = c("None"),
               nsims = 25) |>
  tidy() |>
  filter(term != "(Intercept)", p.value <= 0.05)

## topic 4: less likely in indigenous documents
## topic 1: more likely to appear in indigenous documents (none uncertainty handling only)
## topic 7 less likely to appear incorporate or indigenous documents
summary(seven_mod)
cloud(seven_mod, topic = 4, type = "model")
cloud(seven_mod, topic = 4, type = "documents", documents = docs)
cloud(seven_mod, topic = 1, type = "model")
cloud(seven_mod, topic = 1, type = "documents", documents = docs)
cloud(seven_mod, topic = 7, type = "model")
cloud(seven_mod, topic = 7, type = "documents", documents = docs)

# labeling topics
labelTopics(seven_mod, topics = c(4,1,7), n = 5)

# plotting effects
estimate <- estimateEffect(formula = 1:7~indigenous+corporate+student,
                           stmobj= seven_mod,
                           metadata = meta,
                           documents = docs,
                           uncertainty = c("Global"),
                           nsims = 25)
## topics in indigenous documents
plot(estimate,
     covariate = "indigenous",
     model = seven_mod,
     topics = c(1,2,3,4,5,6,7),
     method = c("difference"),
     cov.value1 = "indigenous",
     cov.value2 = "non-indigenous",
     ci.level = 0.90,
     printlegend = T,
     verbose.labels = F,
     main = "topics 4,1,7 (indigenous compared to non-indigenous documents)")

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


##### for K=11 topics
summary(eleven_mod)
plot(eleven_mod)
estimateEffect(formula = 1:11~indigenous+corporate+student,
               stmobj= eleven_mod,
               metadata = meta,
               documents = docs,
               uncertainty = c("Global"),
               nsims = 25) |>
  tidy() |>
  filter(term != "(Intercept)", p.value <= 0.05)

estimateEffect(formula = 1:11~indigenous+corporate+student,
               stmobj= eleven_mod,
               metadata = meta,
               documents = docs,
               uncertainty = c("Local"),
               nsims = 25) |>
  tidy() |>
  filter(term != "(Intercept)", p.value <= 0.05)

estimateEffect(formula = 1:11~indigenous+corporate+student,
               stmobj= eleven_mod,
               metadata = meta,
               documents = docs,
               uncertainty = c("None"),
               nsims = 25) |>
  tidy() |>
  filter(term != "(Intercept)", p.value <= 0.05)

## topic 5: less likely to be indigenous documents:
##          cloud: human, medic, emerg
#           summary: human, settlement, archaeolog, expert, scent
## topic 3: less likely to be in indigenous documents
##          cloud: truth, residential, history, protect, act, survivor
##          summary: canada, erspect, system, mkultra, constitu, territori, heritag
## topic 1: more likely to be in student documents
##          cloud: security guard
##          summary: guard, security, present, panel, nine (?)
## topic 10: less likely to be in corporate documents
##          cloud: bodies, elder, campus, survivor, dog, mk-ultra, experiment, discovery, indian
##          summary: human, research, residential, school, aleg, contain, patient, experiment
cloud(eleven_mod, topic = 5, type = "model")
cloud(eleven_mod, topic = 5, type = "documents", documents = docs)
cloud(eleven_mod, topic = 3, type = "model")
cloud(eleven_mod, topic = 3, type = "documents", documents = docs)
cloud(eleven_mod, topic = 1, type = "model")
cloud(eleven_mod, topic = 1, type = "documents", documents = docs)
cloud(eleven_mod, topic = 10, type = "model")
cloud(eleven_mod, topic = 10, type = "documents", documents = docs)

# labeling topics (summary from above)
labelTopics(eleven_mod, topics = c(5, 3, 1, 10), n = 5)

# plotting effects
estimate <- estimateEffect(formula = 1:11~indigenous+corporate+student,
                           stmobj= eleven_mod,
                           metadata = meta,
                           documents = docs,
                           uncertainty = c("Global"),
                           nsims = 25)
## topics in indigenous documents
plot(estimate,
     covariate = "indigenous",
     model = eleven_mod,
     topics = c(1:11),
     method = c("difference"),
     cov.value1 = "indigenous",
     cov.value2 = "non-indigenous",
     ci.level = 0.95,
     printlegend = T,
     verbose.labels = F,
     main = "topics in indigenous compared to non-indigenous documents")

# topics in corporate documents
plot(estimate,
     covariate = "corporate",
     model = seven_mod,
     topics = c(1:11),
     method = c("difference"),
     cov.value1 = "corporate",
     cov.value2 = "non-corporate",
     ci.level = 0.95,
     printlegend = T,
     verbose.labels = F,
     main = "topics in corporate compared to non-corporate documents")

# topics in corporate documents
plot(estimate,
     covariate = "student",
     model = seven_mod,
     topics = c(1:11),
     method = c("difference"),
     cov.value1 = "student",
     cov.value2 = "non-student",
     ci.level = 0.95,
     printlegend = T,
     verbose.labels = F,
     main = "topics in student compared to non-student documents")