file = "documents/aptn_fournier_01.txt"

content <- readLines(file)
frontmatter <- yaml::ya ml.load(content)
