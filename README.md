<h1 align="center">
  <br>
  <img src="https://github.com/jocelynpender/fna-query/blob/master/garland_logo.gif">
  <br>
  Query the Flora of North America Semantic MediaWiki
  <br>
</h1>

These scripts allow you to query the `http://beta.semanticfna.org/` [API module "ask"](https://www.semantic-mediawiki.org/wiki/Help:API:ask) using **R or Python**.

  * [Getting started](#getting-started)
    + [Prepare your query](#prepare-your-query)
  * [Use R](#use-r)
  * [Use Python](#use-python)
  * [Getting help](#getting-help)
    + [Bug reports](#bug-reports)
  * [Resources](#resources)
    + [Dependency documentation](#dependency-documentation)
    + [Merging multiple CSV files](#merging-multiple-csv-files)

## Getting started

### Prepare your query

The [Flora of North America Semantic MediaWiki](http://beta.semanticfna.org/) can be queried using the [Semantic MediaWiki semantic search syntax](https://www.semantic-mediawiki.org/wiki/Help:Semantic_search).

In brief, you must have a **condition**: 

`[[Authority::Linnaeus]]`

You can optionally return **properties** of the taxa matching your condition:

`?Distribution`

Sample queries can be found here:
* http://dev.floranorthamerica.org/Sample_Queries

Read more about Semantic MediaWiki query syntax:
* https://www.semantic-mediawiki.org/wiki/Help:Semantic_search
* https://www.semantic-mediawiki.org/wiki/Help:Search_operators

## Use R

<img src=https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/R_logo.svg/724px-R_logo.svg.png title="R" height="100">

This section assumes you are familiar with the R programming language. 

<details><summary><b>Show instructions</b></summary>

### Prerequisites

* [R 3.x](https://www.r-project.org/)
* [WikipediR](https://cran.r-project.org/web/packages/WikipediR/index.html)
* [tidyverse](https://www.tidyverse.org/)

There are two options for getting ready:
#### 1. Manual install of R packages

Open a terminal.

Type `git clone https://github.com/jocelynpender/fna-query.git`

Open an R console. Type
```
install.packages("WikipediR")
install.packages("tidyverse")
```

#### 2. Install packages with packrat

**Why install packages with packrat?**
* The package versions have been tested alongside the R FNA query scripts

Open a terminal.

Type `git clone https://github.com/jocelynpender/fna-query.git`

Open an R console. Type
```
install.packages("packrat")
packrat::unbundle("packrat/bundles/fna-query-2020-01-30.tar.gz", ".")
```

### Run your query
1. Open an R console
2. Open the [run_query.R](https://github.com/jocelynpender/fna-query/blob/master/R/src/run_query.R) script
3. Run your query: 

#### Option A: Return taxa names only (i.e., query does not include ? parameter)
E.g., `[[Distribution::Nunavut]]`

Use `ask_query_titles`.
It returns only a list of Taxon names that match your query.

In the `fna-query` directory, run
```
source("R/src/query.R")
page_titles_vector <- ask_query_titles("[[Distribution::Nunavut]]", "output_file_name.csv")
```

#### Option B: Return taxa names and properties (i.e., query includes a ? parameter)
E.g., `[[Distribution::Nunavut]]|?Taxon family`

Use `ask_query_titles_properties`
It returns a list of Taxon names **and** associated properties asked for by your query

In the `fna-query` directory, run
```
source("R/src/query.R")
properties_texts_data_frame <- ask_query_titles_properties("[[Distribution::Nunavut]]|?Taxon family", "output_file_name.csv")
```

### Expected output

#### Option A: Return taxa names only (i.e., query does not include ? parameter)
E.g., `[[Distribution::Nunavut]]`
```
> page_titles_vector

[1] "Abietinella abietina"                     
[2] "Achillea millefolium"                     
[3] "Agrostis"                                 
[4] "Agrostis anadyrensis"        
 ...
```

See https://github.com/jocelynpender/fna-query/blob/master/R/demo_queries/distribution/nunavut_taxa.csv for a sample output file.

#### Option B: Return taxa names and properties (i.e., query includes a ? parameter)
E.g., `[[Distribution::Nunavut]]|?Taxon family`
```
> properties_texts_data_frame
                                            Taxon family
Abietinella abietina                         Thuidiaceae
Achillea millefolium                          Asteraceae
Agrostis                                         Poaceae
Agrostis anadyrensis                             Poaceae   
 ...
```

See https://github.com/jocelynpender/fna-query/blob/master/R/demo_queries/distribution/nunavut_taxa_family_name.csv for a sample output file.

### Run a demo query

Don't know what to query? See the demo queries here:
https://github.com/jocelynpender/fna-query/tree/master/R/demo_queries
</details>

## Use Python

<img src="https://upload.wikimedia.org/wikipedia/commons/f/f8/Python_logo_and_wordmark.svg" title="Python" height="100">

This section assumes you are familiar with Python programming. 

<details><summary><b>Show instructions</b></summary>

### Prerequisites

#### Create an account

You'll need to create an account to use the API with Python

1. Create your account
http://beta.floranorthamerica.org/Special:CreateAccount

2. Create a file called `local.py` with your credentials. It should look like this:

```
USERNAME = 'User'
PASSWORD = 'Password'
```

#### Dependencies

* [Python 3.7](https://www.python.org/)
* [mwclient](https://pypi.org/project/mwclient/)
* [pandas](https://pypi.org/project/pandas/)

#### 1. Use pip

`requirements.txt` has been generated with `pip freeze > requirements.txt`

Open a terminal.
```git clone https://github.com/jocelynpender/fna-query.git
cd fna-query
pip install -r requirements.txt
```

#### 2. Use conda

The project was built within a conda environment. A conda YAML file has been generated with `conda env export > fna-query.yml`.

Open a terminal.
```git clone https://github.com/jocelynpender/fna-query.git
cd fna-query
conda env create -f fna-query.yml
```

### Run your query

1. Open a terminal.
2. Prepare your query. E.g., `[[Special status::Introduced]]`
3. Run your query using:
```
cd python
python -m src.run_query --output_file_name "output_file_name.csv" --query_string "[[Query::here]]"
```

The `-m` flag tells Python to run the script `run_query.py` and **import the src module**.

### Expected output

If your query results are extensive, the query will take some time to process. Please be patient. 

#### Option A: Taxa names only (i.e., query does not include ? parameter)
E.g., `[[Illustrator::+]][[Illustration::Present]]`

`python -m src.run_query --output_file_name "illustrated_taxa.csv" --query_string "[[Illustrator::+]][[Illustration::Present]]"`

See

#### Option B: Taxa names and properties (i.e., query includes a ? parameter)
E.g., `[[Illustrator::+]][[Illustration::Present]]|?Taxon family`

`python -m src.run_query --output_file_name "illustrated_taxa_taxon_family.csv" --query_string "[[Illustrator::+]][[Illustration::Present]]|?Taxon family"`

See

### Run a demo query

Don't know what to query? See the demo queries here:
https://github.com/jocelynpender/fna-query/tree/master/python/demo_queries

</details>

## Getting help

Contact me at jocelyn.pender@canada.ca for support.

### Bug reports

Please leave your bug reports here: 
https://github.com/jocelynpender/fna-query/issues

## Resources

### Dependency documentation

* Read more about [the WikipediR package for R](https://cran.r-project.org/web/packages/WikipediR/WikipediR.pdf). 
* Read more about the [mwclient for Python](https://mwclient.readthedocs.io/en/latest/index.html).

### Merging multiple CSV files
Sometimes you'll need to batch the API return results. Here is an [R script for merging multiple CSV files](https://github.com/jocelynpender/fna-query/blob/master/R/src/merge.R).
