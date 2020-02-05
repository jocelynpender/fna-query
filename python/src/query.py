from mwclient import Site
import pandas as pd
import re
import src.local  # create a file called local.py with your credentials


def site_login():
    """
    Log-in to the Semantic MediaWiki using a USERNAME and PASSWORD
    Create a file called local.py with your credentials
    """
    site = Site(('http', 'beta.floranorthamerica.org'))
    site.login(src.local.USERNAME, src.local.PASSWORD)
    return site


def extract_property_text(printouts, property):
    """
    Extract property data from the data returned by the API (="printouts") for a property

    Parameters
    ----------
    printouts: query results returned by the site.ask query function
    property: property name (e.g., Illustrator, Distribution, etc.)

    Returns
    -------
    property_text: isolated property text string for the property in question

    """
    property_text = printouts[property]
    if len(property_text) == 1:
        property_text = property_text[0]
        if isinstance(property_text, dict): # If the property is a page type, it returns a dictionary
            property_text = property_text['fulltext'] # with namespace, url, etc. 'fulltext' is what we want
    return property_text


def extract_taxon_properties(site, query_string, properties):
    """
    Return taxa names matched by a query string, as well as the property data asked for in a list
    using the mwclient function "ask".

    Parameters
    ----------
    site: a logged-in Site object of the flora
    query_string: a query string to run ask SMW ask query API
    properties: a list of the properties you'd like to return

    Returns
    -------
    taxon_names: a list of the taxon name returned to match to the property data returned
    property_texts: a list of property text data asked for by the query string
    """
    properties_texts = []
    taxon_names = []

    for answer in site.ask(query_string):  # use a for loop to collect properties and other things we want to store!
        for title, data in answer.items():
            if title == 'printouts':
                properties_texts.append([extract_property_text(data, property) for property in properties])
            if title == 'fulltext':
                taxon_names.append(data)
                print("Appending {} data".format(data))

    return taxon_names, properties_texts


def ask_query(query_string, output_file_name):
    """
    Run an ask query against the API module "ask" using the mwclient function "ask".

    Parameters
    ----------
    output_file_name: output file name
    query_string: a query string to run ask SMW ask query API, e.g.:

    # query_string = "[[Authority::Linnaeus]][[Distribution::Nunavut]]|?Taxon family"
    # query_string = "[[Authority::Miller]]|?Taxon family|?Volume"
    # query_string = "[[Distribution::Ont.]][[Author::Geoffrey A. Levin]]|?Taxon family|?Volume|?Illustration|?Distribution"
    # query_string = "[[Distribution::Ont.]][[Author::Geoffrey A. Levin]]|?Taxon family|?Volume|?Distribution"
    # query_string = "[[Illustrator::+]][[Illustration::Present]]"

    Returns
    -------
    properties_texts_data_frame: a pandas dataframe with matched taxa names and properties

    """
    site = site_login()
    properties = re.split(r'\|\?', query_string)[1:]
    taxon_names, properties_texts = extract_taxon_properties(site, query_string, properties)
    properties_texts = pd.DataFrame(properties_texts, columns=properties)
    properties_texts_data_frame = pd.concat([pd.Series(taxon_names), properties_texts], axis=1)
    properties_texts_data_frame = properties_texts_data_frame.rename(columns={0: "Taxon name"})
    properties_texts_data_frame.to_csv(output_file_name, index=False)
    return properties_texts_data_frame
