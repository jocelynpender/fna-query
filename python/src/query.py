from mwclient import Site
import pandas as pd
import re
import local  # create a file called local.py with your credentials


def site_login():
    """
    Log-in to the Semantic MediaWiki using a USERNAME and PASSWORD
    Create a file called local.py with your credentials
    """
    site = Site(('http', 'beta.floranorthamerica.org'))
    site.login(local.USERNAME, local.PASSWORD)  # create a file called local.py with your credentials
    return site


def ask_query_titles(query_string, output_file_name):
    """
    Run a query and save page title results in a csv

    Parameters
    ----------
    query_string:
    e.g., query_string = "[[Authority::Linnaeus]][[Distribution::Nunavut]]"

    output_file_name

    Returns
    -------

    """
    site = site_login()
    page_titles = [answer["fulltext"] for answer in site.ask(query_string)]  # fulltext key is the page title
    page_titles_data_frame = pd.DataFrame(page_titles)
    page_titles_data_frame.to_csv(output_file_name, header=False, index=False)
    return page_titles_data_frame


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


def extract_taxon_properties(item, properties):
    """

    Parameters
    ----------
    item
    properties

    Returns
    -------

    """
    taxon_name = item['fulltext']
    printouts = item['printouts']  # the API query returns "printouts" of the requested property texts as the first
    # element of the data

    property_texts = [extract_property_text(printouts, property) for property in properties]
    property_texts.insert(0, taxon_name)
    return property_texts


def ask_query_titles_properties(query_string, output_file_name):
    """

    Parameters
    ----------
    query_string

    # query_string = "[[Authority::Linnaeus]][[Distribution::Nunavut]]|?Taxon family"
    # query_string = "[[Authority::Miller]]|?Taxon family|?Volume"
    # query_string = "[[Distribution::Ont.]][[Author::Geoffrey A. Levin]]|?Taxon family|?Volume|?Illustration|?Distribution"
    # query_string = "[[Distribution::Ont.]][[Author::Geoffrey A. Levin]]|?Taxon family|?Volume|?Distribution"

    output_file_name

    Returns
    -------

    """
    site = site_login()
    generator = site.ask(query_string)
    data = list(generator)
    properties = re.split(r'\|\?', query_string)[1:]
    properties_texts = [extract_taxon_properties(item, properties) for item in data]
    properties.insert(0, 'Taxon name')  # Convert the list to appropriate column names
    properties_texts_data_frame = pd.DataFrame(properties_texts, columns=properties)
    properties_texts_data_frame.to_csv(output_file_name, header=False, index=False)
    return properties_texts_data_frame
