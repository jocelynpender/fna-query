require("WikipediR")
require(tidyverse)


ask_query_url <- function(query_string) {
  # Concatenate a query_string with the http api URL for a Semantic MediaWiki instance
  base_url = "http://beta.semanticfna.org/w/api.php?action=ask&query="
  url = paste(base_url, query_string, sep = "")
  return(url)
}

query_page_titles <- function(query_results) {
  # Take query results returned by the WikipediR query function
  # and transform them into a list of page title results
  page_titles <- query_results$query$results %>% map(~ .$fulltext)
  page_titles_list <- page_titles %>% unlist
  names(page_titles_list) <- FALSE  # Strip off list names
  return(page_titles_list)
}


query_property_text <- function(query_results, property) {
  printouts <- query_results$query$results %>% map(~ .$printouts) # the API query returns "printouts" of the requested property texts
  unlisted_printouts <- printouts %>% unlist
  property_text_labels <- names(printouts) %>% paste(., property, sep=".") # paste the Taxon name returned with the property name to get the label for selecting the property text returned by the query
  property_text <- unlisted_printouts[property_text_labels] # select the property texts using "Taxon name.Property name"
  if (is.na(property_text) %>% sum(.) == length(property_text)) { # If the above returns no hits, the property text may be stored as "fulltext"
    property_text_labels_full_text <- paste(property_text_labels, "fulltext", sep=".")
    property_text <- unlisted_printouts[property_text_labels_full_text]
  }
  names(property_text) <- names(property_text) %>% gsub(paste(".", property, ".fulltext", sep=""), "", .) # Clean up property text labels
  return(property_text)
}


ask_query_titles <- function(query_string, output_file_name) {
  # Run a query and save page title results in a csv
  # e.g., query_string = "[[Authority::Linnaeus]][[Distribution::Nunavut]]"
  url <- ask_query_url(query_string)
  query_results <- query(url, out_class = "none")
  page_titles_list <- query_page_titles(query_results)
  write.csv(page_titles_list, output_file_name)
}


ask_query_titles_properties <- function(query_string, output_file_name) {
  # query_string = "[[Authority::Miller]]|?Taxon family|?Volume"
  query_string = "[[Distribution::Ont.]][[Author::Geoffrey A. Levin]]|?Taxon family|?Volume|?Illustration"
  # "[[Distribution::Ont.]][[Author::Geoffrey A. Levin]]|?Taxon family|?Volume|?Distribution"
  url <- ask_query_url(query_string)
  query_results <- query(url, out_class = "none")
  properties <- strsplit(query_string, "\\|\\?") %>% map(~ .[2:length(.)]) %>% unlist
  properties_texts <- properties %>% map(~ query_property_text(query_results, property = .))
  properties_texts_data_frame <- do.call(rbind, properties_texts) %>% t
  write.csv(properties_texts_data_frame, output_file_name)
}