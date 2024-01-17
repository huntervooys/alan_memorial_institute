library(lubridate)
library(dplyr)

files <- list.files("documents", pattern = "*.txt", full.names = TRUE)

# Initialize an empty data frame
df <- data.frame(
    num_date = numeric(),
    indigenous = logical(),
    corporate = logical(),
    student = logical(),
    publisher = character(),
    sentence = character()
)

for (file in files) {
    content <- readLines(file)
    content <- gsub("@", "_", content)
    fm <- yaml::yaml.load(content[1:8])  # renamed variable to fm

    indigenous <- "indigenous" %in% fm$tags
    corporate <- "corporate" %in% fm$tags
    student <- "student" %in% fm$tags

    date <- mdy(fm$date)
    date <- POSIXct(date, tz = "EST")
    num_date <- as.numeric(date)

    publisher <- fm$publisher

    for (line in content[10:length(content)]) {
        
        # Create a new data frame for this line
        line_df <- data.frame(
            num_date = num_date, 
            indigenous = indigenous, 
            corporate = corporate, 
            student = student, 
            publisher = publisher, 
            sentence = line)
    
        # Bind the new data frame to the existing data frame
        df <- bind_rows(df, line_df)
    }    
}


print(df)
