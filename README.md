# alan_memorial_institute
 This repo will contain data related to the the grounds of Royal Victoria Hospital (a corpus of legal documents) and code used in its analysis.

# The Corpus

the corpus is available in 2 formats, one of which is in the data directory and the other of which is in the documents directory.

## The data directory

includes all of the documents, minimally processed with YAML frontmatter in the following format:

```
---
title: cadaver-dogs-sniff-out-potential-human-remains-near-old-royal-victoria-hospital-site
author: Emelia Fournier
publisher: aptn news
URL: https://www.aptnnews.ca/national-news/cadaver-dogs-sniff-out-potential-human-remains-near-old-royal-victoria-hospital-site/
summary: 
tags: 
    - news
    - indigenous
---
```

## The Documents directory

(**this directory is currently being modified**): includes all documents with the following YAML frontmatter. Documents in this corpus also have common phrases replaced by a single token to aid in later processing steps (i.e., as a normalization step)

The data is modified to include the following tags:

* '@McGill' : any noun/determiner phrase referring directly to McGill University
* '@MohawkMothers' : any noun/determiner phrase (in any langauge) referring directly to the Kahnistensera
* '@RVH' : any noun/determiner phrase referring directly to the Royal Victoria Hospital, or the site of Royal Victoria Hospital
* '@MUHC' : any noun/determiner phrase referring directly to the McGill University Health Center
* '@MKULTRA' : any referrence to MKULTRA experiments
* '@AMI' : any reference specifically to the Alan Memorial Institute or its site
* '@NVP' : any noun/determiner phrase referring to the New Vic Project 
* '@CIA' : any noun/determiner phrase referring to the CIA

```
title: Dogs sniff out potential human remains
author: Emelia Fournier
publisher: aptn news
date: 06/29/2023
URL: https://www.aptnnews.ca/national-news/cadaver-dogs-sniff-out-potential-human-remains-near-old-royal-victoria-hospital-site/
mentioned: @McGill, @MohawkMothers @RVH, @SQI, @MUHC, @AMI, @CIA, @NVP
tags:  news, indigenous
---
```