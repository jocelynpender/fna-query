require("WikipediR")
require("tidyverse")


ask_query_url <- function(query_string) {
  # Concatenate a query_string with the http API ask query module URL
  # for the FNA Semantic MediaWiki instance
  base_url = "http://beta.semanticfna.org/w/api.php?action=ask&query="
  url = paste(base_url, query_string, sep = "")
  return(url)
}

run_query <- function(query_string) {
  # Run a query against the Semantic MediaWiki http api URL and obtain results back
  # in R
  url <- ask_query_url(query_string)
  query_results <- query(url, out_class = "none") # Uses the WikipediR query function
  return(query_results)
}

query_page_titles <- function(query_results) {
  # Input: query results returned by the WikipediR query function 
  # Output: a list of page title results
  page_titles <- query_results$query$results %>% map(~.$fulltext) %>% unlist
  page_titles_vector <- as.vector(page_titles)
  return(page_titles_vector)
}


query_property_texts <- function(printouts, property) {
  # This function is used to isolate property text from other query results 
  # returned by the WikipediR query function and return property texts in a clean named vector
  # that can be placed inside a dataframe.
  # This function handles the differences in returned data between property types (string property, 
  # page property, properties with multiple possible values)
  # Input: 
  # printouts: query results returned by the WikipediR query function 
  # property: property name (e.g., Illustrator, Distribution, etc.)
  # Output: a named vector with property text as values and Taxon name as vector names
  unlisted_printouts <- printouts %>% unlist
  property_text_labels <- names(printouts) %>% paste(., property, sep = ".")  # paste the Taxon name
  # with the property name to get the label for selecting the property text returned by the query
  property_text <- unlisted_printouts[property_text_labels]  # select the property texts using
  # 'Taxon name.Property name'. This will collect data perfectly well for string properties.
  grepped_property_text_labels = property_text_labels %>% map(~names(unlisted_printouts)[grepl(., 
    names(unlisted_printouts))]) %>% unlist # This takes the above 'Taxon name.Property name'
  # labels and matches them everywhere within the label list. If a property is stored as
  # fulltext because it is a page type there will be more than one hit per 'Taxon name.Property name'
  # (one each for fulltext, fullurl, namespace, etc.) or it has more than one returned value, 
  # there will be multiple hits per label, e.g., 'Taxon name.Property name2', 'Taxon name.Property name3', ...
  if (length(grepped_property_text_labels) > length(property_text)) {
    property_text_labels_full_text <- paste(property_text_labels, "fulltext", 
      sep = ".") # this works for property type = page
    property_text <- unlisted_printouts[property_text_labels_full_text]
    if (any(grepl("\\d$", grepped_property_text_labels))) { # alternatively, this grabs text 
      # if properties are numbered
      property_text <- unlisted_printouts[grepped_property_text_labels]
    }
  }
  names(property_text) <- names(property_text) %>% gsub(property, "", .) %>% gsub("fulltext", 
    "", .) %>% gsub("\\d", "", .) %>% gsub("\\.", "", .)  # Clean up property text labels
  return(property_text)
}


properties_texts_to_data_frame <- function(properties_texts, properties) {
  # Input: 
  # properties_texts: a list of property results with associated Taxon names as names(list)
  # properties: the names of the properties, used to set column names
  # Output: a left-joined data frame housing all property text/Taxon name combinations
  properties_texts_list <- properties_texts %>% map(~data.frame(., names(.)))  # Build data frames
  properties_texts_list <- lapply(seq_along(properties_texts_list), function(i) setNames(properties_texts_list[[i]], 
    c(properties[i], "Taxon name")))  # Fix up column names
  properties_texts_data_frame <- properties_texts_list %>% reduce(left_join, by = "Taxon name")  # Left join of data frames by Taxon name
  return(properties_texts_data_frame)
}


ask_query_titles <- function(query_string, output_file_name) {
  # Run a query and save page title results in a csv e.g., query_string =
  # '[[Authority::Linnaeus]][[Distribution::Nunavut]]'
  query_results <- run_query(query_string)
  page_titles_vector <- query_page_titles(query_results)
  write.csv(page_titles_vector, output_file_name)
  return(page_titles_vector)
}


ask_query_titles_properties <- function(query_string, output_file_name) {
  # Input:
  # output_file_name: self-explanatory
  # query_string: a query string to run ask SMW ask query API, e.g.:
  # '[[Distribution::Ont.]][[Author::Geoffrey A. Levin]]|?Taxon family|?Volume|?Distribution' 
  # Output: a csv and a data frame holding Taxon
  # names returned and the property values asked for
  query_results <- run_query(query_string)
  properties <- strsplit(query_string, "\\|\\?") %>% map(~.[2:length(.)]) %>% unlist
  printouts <- query_results$query$results %>% map(~.$printouts)  # the API query returns 'printouts' of the requested property texts
  properties_texts <- properties %>% map(~query_property_texts(printouts, property = .))
  properties_texts_data_frame <- properties_texts_to_data_frame(properties_texts, 
    properties)
  write.csv(properties_texts_data_frame, output_file_name)
  return(properties_texts_data_frame)
}
