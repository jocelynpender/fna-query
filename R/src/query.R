require("WikipediR")
require("tidyverse")

ask_query_url <- function(query_string, query_param) {
  # Concatenate a query_string with the http API ask query module URL
  # for the FNA Semantic MediaWiki instance
  base_url <- "http://beta.semanticfna.org/w/api.php?action=ask&query="
  seps <- list(pipe = "%7C", eq = "%3D")
  prep_params <- map2(names(query_param), query_param, ~ paste(.x, .y, sep=seps$eq))
  paste_params <- paste(c("", prep_params), collapse=seps$pipe, sep=seps$pipe)
  url <- paste(base_url, query_string, paste_params, sep = "")
  return(url)
}

run_query <- function(query_string) {
  # Run a query against the Semantic MediaWiki http api URL and obtain results back in R
  query_offset = 0
  query_results_list <- list() # Need to initialize the list, then add to it in the loop
  while (!is.null(query_offset) == TRUE) { # While there continues to be an offset...
    url <- ask_query_url(query_string, query_param = list(limit = "500", offset = query_offset))
    query_results <- query(url, out_class = "none") # Uses the WikipediR query function
    query_results_list[[length(query_results_list) + 1]] <- query_results$query$results
    print(paste("Appending batch", query_offset, "-",
                ifelse(is.null(query_results$`query-continue-offset`), "end", query_results$`query-continue-offset` - 1),
                "to query results")) # Give an indication of progress of the download
    query_offset <- query_results$`query-continue-offset`
  }
  query_results_list <- do.call(c, query_results_list) # Fix up list formatting
  return(query_results_list)
}

query_page_titles <- function(query_results) {
  # Return page titles that match a query
  # Input: query results returned by the WikipediR query function 
  # Output: a list of page title results
  page_titles <- query_results %>% map(~.$fulltext) %>% unlist
  page_titles_vector <- as.vector(page_titles)
  return(page_titles_vector)
}


query_page_property_texts <- function(printouts, unlisted_printouts, property) {
  property_fulltext <- paste(property, "fulltext", sep = ".")
  property_text <- unlisted_printouts %>% .[grepl(property_fulltext, names(.))] # this works for property type = page
  names(property_text) <- names(printouts)
  return(property_text)
}


query_property_texts <- function(printouts, property) {
  # This function is used to isolate property text from other query results 
  # returned by the WikipediR query function and return property texts in a clean named vector
  # that can be placed inside a dataframe.
  # This function handles the differences in returned data between property types (string property, 
  # page property, properties with multiple possible values)
  # Input: 
    # printouts: query results returned by the WikipediR query functionm (full set of results) 
    # property: property name you wish to extract from the results (e.g., Illustrator, Distribution, etc.)
  # Output: a named vector with property text as values and Taxon name as vector names
  unlisted_printouts <- printouts %>% unlist
  property_text_labels <- names(printouts) %>% paste(., property, sep = ".")  # paste the Taxon name
  # with the property name to get the label for selecting the property text returned by the query
  matched_property_text_labels <- sum(property_text_labels %in% names(unlisted_printouts))
  if (matched_property_text_labels == 0) {
    property_text <- query_page_property_texts(printouts, unlisted_printouts, property)
  } else {
    property_text <- unlisted_printouts %>% .[grepl(property, names(.))]
    names(property_text) <- lapply(names(property_text), function(x) strsplit(x, "\\.\\S")[[1]][1]) %>% unlist # Clean this up
  }
  return(property_text)
}

properties_texts_to_data_frame <- function(properties_texts, properties) {
  # Transform property texts into a dataframe
  # Input: 
  # properties_texts: a list of property results with associated Taxon names as names(list)
  # properties: the names of the properties, used to set column names
  # Output: a left-joined data frame housing all property text/Taxon name combinations
  properties_texts_list <- properties_texts %>% map(~data.frame(., names(.)))  # Build data frames
  properties_texts_list <- lapply(seq_along(properties_texts_list), function(i) setNames(properties_texts_list[[i]], 
    c(properties[i], "Taxon name")))  # Fix up column names
  properties_texts_data_frame <- properties_texts_list %>% reduce(full_join, by = "Taxon name")  # Outer join of data frames by Taxon name
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

query_string_to_data_frame <- function(query_string, query_results) {
  # Run the query string to property texts dataframe pipeline
  # Input: query string
  # Output: a dataframe containing property text data with names
  properties <- strsplit(query_string, "\\|\\?") %>% map(~.[2:length(.)]) %>% unlist
  printouts <- query_results %>% map(~.$printouts)  # the API query returns 'printouts' of the requested property texts
  properties_texts <- properties %>% map(~query_property_texts(printouts, property = .))
  properties_texts_data_frame <- properties_texts_to_data_frame(properties_texts, 
                                                                properties)
  return(properties_texts_data_frame)
}

ask_query_titles_properties <- function(query_string, output_file_name) {
  # Run the entire workflow from query string to output file
  # Input:
  # output_file_name: output file name
  # query_string: a query string to run ask SMW ask query API, e.g.:
  # '[[Distribution::Ont.]][[Author::Geoffrey A. Levin]]|?Taxon family|?Volume|?Distribution' 
  # Output: a csv and a data frame holding Taxon
  # names returned and the property values asked for
  query_results <- run_query(query_string)
  properties_texts_data_frame <- data.frame()
  properties_texts_data_frame <- query_string_to_data_frame(query_string, query_results)
  write.csv(properties_texts_data_frame, output_file_name)
  return(properties_texts_data_frame)
}
