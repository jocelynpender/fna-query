from mwclient import Site
import pandas as pd
import local  # create a file called local.py with your credentials


def query_titles(query):
    """

    """
    #  query = "[[Authority::Linnaeus]][[Distribution::Nunavut]]"

    site = Site(('http', 'beta.floranorthamerica.org'))
    site.login(local.USERNAME, local.PASSWORD)  # create a file called local.py with your credentials
    page_titles = [answer["fulltext"] for answer in site.ask(query)]  # fulltext key is the page title
    page_titles_data_frame = pd.DataFrame(page_titles)
    page_titles_data_frame.to_csv("page_titles_python.csv", header=False, index=False)
    return page_titles_data_frame
