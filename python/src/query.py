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
    site.login(src.local.USERNAME, src.local.PASSWORD)  # create a file called local.py with your credentials
    return site


def extract_property_text(printouts, property):
    """

    Parameters
    ----------
    printouts
    property

    Returns
    -------

    """
    property_text = printouts[property]
    if len(property_text) == 1:
        property_text = property_text[0]
        if isinstance(property_text, dict):
            property_text = property_text['fulltext']
    return property_text


def extract_taxon_properties(site, query_string, properties):
    """

    Parameters
    ----------
    item
    properties

    Returns
    -------
    property_texts:

    # use a for loop to collect properties and other things we want to store! No need to convert the full generator

    """
    properties_texts = []
    taxon_names = []

    for answer in site.ask(query_string):
        for title, data in answer.items():
            if title == 'printouts':
                properties_texts.append([extract_property_text(data, property) for property in properties])
            if title == 'fulltext':
                taxon_names.append(data)

    return taxon_names, properties_texts


def ask_query(query_string, output_file_name):
    """

    Parameters
    ----------
    output_file_name: output file name
    query_string: a query string to run ask SMW ask query API, e.g.:

    # query_string = "[[Authority::Linnaeus]][[Distribution::Nunavut]]|?Taxon family"
    # query_string = "[[Authority::Miller]]|?Taxon family|?Volume"
    # query_string = "[[Distribution::Ont.]][[Author::Geoffrey A. Levin]]|?Taxon family|?Volume|?Illustration|?Distribution"
    # query_string = "[[Distribution::Ont.]][[Author::Geoffrey A. Levin]]|?Taxon family|?Volume|?Distribution"

    Returns
    -------
    properties_texts_data_frame:

    """
    site = site_login()
    properties = re.split(r'\|\?', query_string)[1:]
    taxon_names, properties_texts = extract_taxon_properties(site, query_string, properties)
    properties_texts = pd.DataFrame(properties_texts, columns=properties)
    properties_texts_data_frame = pd.concat([pd.Series(taxon_names), properties_texts], axis=1)
    properties_texts_data_frame = properties_texts_data_frame.rename(columns={0: "Taxon name"})
    properties_texts_data_frame.to_csv(output_file_name, index=False)
    return properties_texts_data_frame

# TO DO
# time the list() vs. DataFrame() vs. for loop and appending for a shorter query

# query_string = "[[Illustrator::+]][[Illustration::Present]]"