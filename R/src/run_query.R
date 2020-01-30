# Run this file inside an R console
source("R/src/query.R")

# Use this function to return a list of Taxon names that match your query
page_titles_vector <- ask_query_titles(query_string, output_file_name)
  
# Use this function to return a list of Taxon names and associated properties asked for by your query
properties_texts_data_frame <- ask_query_titles_properties(query_string, output_file_name)