require("WikipediR")
require(tidyverse)


ask_query_url <- function(query_string) {
  # Concatenate a query_string with the http api URL for a Semantic MediaWiki instance
  base_url = "http://beta.semanticfna.org/w/api.php?action=ask&query="
  url = paste(base_url, query_string, sep = "")
  return(url)
}

query_page_titles <- function(query_results) {
  # Input: query results returned by the WikipediR query function
  # Output: a list of page title results
  page_titles <- query_results$query$results %>% map(~ .$fulltext)
  page_titles_list <- page_titles %>% unlist
  names(page_titles_list) <- FALSE  # Strip off list names
  return(page_titles_list)
}


query_property_texts <- function(query_results, property) {
  # Input: query results returned by the WikipediR query function
  # Output: a named vector with property text as vlues and Taxon name as vector names
  printouts <- query_results$query$results %>% map(~ .$printouts) # the API query returns "printouts" of the requested property texts
  unlisted_printouts <- printouts %>% unlist
  property_text_labels <- names(printouts) %>% paste(., property, sep=".") # paste the Taxon name returned with the property name to get the label for selecting the property text returned by the query
  property_text <- unlisted_printouts[property_text_labels] # select the property texts using "Taxon name.Property name"
  grepped_property_text_labels = property_text_labels %>% map(~ names(unlisted_printouts)[grepl(., names(unlisted_printouts))]) %>% unlist
  if (length(grepped_property_text_labels) > length(property_text)) { # If the above returns no hits, the property text may be stored as "fulltext"
    property_text_labels_full_text <- paste(property_text_labels, "fulltext", sep=".")
    property_text <- unlisted_printouts[property_text_labels_full_text]
    if (any(grepl('\\d$', grepped_property_text_labels))) { # if properties are numbered
      property_text <- unlisted_printouts[grepped_property_text_labels] }
    }
  names(property_text) <- names(property_text) %>% gsub(property, "", .) %>% gsub("fulltext", "", .) %>% gsub("\\d", "", .) %>% gsub("\\.", "", .) # Clean up property text labels
  return(property_text)
}


properties_texts_to_data_frame <- function(properties_texts, properties) {
  # Input: a list of property results with associated Taxon names
  # Output: a left-joined data frame housing all property text/Taxon name combinations
  properties_texts_list <- properties_texts %>% map(~ data.frame(., names(.))) # Build data frames
  properties_texts_list <- lapply(seq_along(properties_texts_list), function(i) setNames(properties_texts_list[[i]], c(properties[i], "Taxon name"))) # Fix up column names
  properties_texts_data_frame <- properties_texts_list %>% reduce(left_join, by = "Taxon name") # Left join of data frames by Taxon name
  return (properties_texts_data_frame)
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
  # Input: a query string to run ask SMW ask query API
  # Examples:
  # query_string = "[[Authority::Miller]]|?Taxon family|?Volume"
  # query_string = "[[Distribution::Ont.]][[Author::Geoffrey A. Levin]]|?Taxon family|?Volume|?Illustration|?Distribution"
  # query_string = "[[Distribution::Ont.]][[Author::Geoffrey A. Levin]]|?Taxon family|?Volume|?Distribution"
  # Output: a csv and a data frame holding Taxon names returned and the property values asked for
  url <- ask_query_url(query_string)
  query_results <- query(url, out_class = "none")
  properties <- strsplit(query_string, "\\|\\?") %>% map(~ .[2:length(.)]) %>% unlist
  properties_texts <- properties %>% map(~ query_property_texts(query_results, property = .))
  properties_texts_data_frame <- properties_texts_to_data_frame(properties_texts, properties)
  write.csv(properties_texts_data_frame, output_file_name)
  return (properties_texts_data_frame)
}