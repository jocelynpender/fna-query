# Query the Flora of North America Semantic MediaWiki

These scripts leverage the `http://beta.semanticfna.org/` API.

  * [Getting started](#getting-started)
    + [Prepare your query](#prepare-your-query)
    + [Use R](#use-r)
    + [Use Python](#use-python)
  * [Getting help](#getting-help)
    + [Bug reports](#bug-reports)
  * [Resources](#resources)
    + [Dependency documentation](#dependency-documentation)
    + [Merging Multiple CSV Files](#merging-multiple-csv-files)

## Getting started

You can use R or Python to programmatically query the Flora of North America. 

### Prepare your query

The Flora of North America Semantic MediaWiki can be queried using the Semantic MediaWiki semantic search syntax.

In brief, you must have a **condition**: 
`[[Authority::Linnaeus]]`

You can optionally return **properties** of the taxa matching your condition:
`?Distribution`

Read more about Semantic MediaWiki query syntax:
* https://www.semantic-mediawiki.org/wiki/Help:Semantic_search
* https://www.semantic-mediawiki.org/wiki/Help:Search_operators

### Use R

This section assumes you are familiar with the R programming language. 

#### Prerequisites

* R 3.x
* WikipediR
* tidyverse

There are two options for getting ready:
##### 1. Manual install of R packages

Open a terminal.
Type `git clone https://github.com/jocelynpender/fna-query.git`

Open an R console. Type
```
install.packages("WikipediR")
install.packages("tidyverse")
```

##### 2. Install packages with packrat

The benefit to installing packages with packrat:
* The package versions have been tested alongside the R FNA query scripts

Open a terminal.
Type `git clone https://github.com/jocelynpender/fna-query.git`

Open an R console. Type
```
install.packages("packrat")
packrat::unbundle("packrat/bundles/fna-query-2020-01-30.tar.gz", "<path_to_your_dir>")
```

#### Usage
1. Open an R console
2. Open the [https://github.com/jocelynpender/fna-query/blob/master/R/src/run_query.R](run_query.R) script
3. Prepare your query: 

##### Option A: Return taxa names only (i.e., query does not include ? parameter)
E.g., `[[Distribution::Nunavut]]`

Use `ask_query_titles`
Returns only a list of Taxon names that match your query

In the `fna-query` directory, run
```
source("R/src/query.R")
page_titles_vector <- ask_query_titles("[[Distribution::Nunavut]]", "output_file_name.csv")
```

##### Option B: Return taxa names and properties (i.e., query includes a ? parameter)
E.g., `[[Distribution::Nunavut]]|?Taxon family`

Use `ask_query_titles_properties`
Returns a list of Taxon names **and** associated properties asked for by your query

In the `fna-query` directory, run
```
source("R/src/query.R")
properties_texts_data_frame <- ask_query_titles_properties("[[Distribution::Nunavut]]|?Taxon family", "output_file_name.csv")
```

#### Expected output

##### Option A: Return taxa names only (i.e., query does not include ? parameter)
E.g., `[[Distribution::Nunavut]]`
```
page_titles_vector

[1] "Abietinella abietina"                     
[2] "Achillea millefolium"                     
[3] "Agrostis"                                 
[4] "Agrostis anadyrensis"        
 ...
```

See https://github.com/jocelynpender/fna-query/blob/master/R/demo_queries/distribution/nunavut_taxa.csv

##### Option B: Return taxa names and properties (i.e., query includes a ? parameter)
E.g., `[[Distribution::Nunavut]]|?Taxon family`
```
properties_texts_data_frame
                                            Taxon family
Abietinella abietina                         Thuidiaceae
Achillea millefolium                          Asteraceae
Agrostis                                         Poaceae
Agrostis anadyrensis                             Poaceae   
 ...
```

See https://github.com/jocelynpender/fna-query/blob/master/R/demo_queries/distribution/nunavut_taxa_family_name.csv

#### Run a demo query

Don't know what to query? See the demo queries here:
https://github.com/jocelynpender/fna-query/tree/master/R/demo_queries

### Use Python

This section assumes you are familiar with Python programming. 

#### Prerequisites

##### Create an account

You'll need to create an account to use the API with Python

1. Create your account
http://beta.floranorthamerica.org/Special:CreateAccount

2. Create a file called `local.py` with your credentials. It should look like this:

```
USERNAME = 'User'
PASSWORD = 'Password'
```

##### Dependencies

* Python 3.7
* mwclient
* pandas

##### 1. Use pip

`requirements.txt` has been generated with `pip freeze > requirements.txt`

Open a terminal.
```git clone https://github.com/jocelynpender/fna-query.git
cd fna-query
pip install -r requirements.txt
```

##### 2. Use conda

The project was built within a conda environment. A conda YAML file has been generated with `conda env export > fna-query.yml`.

Open a terminal.
```git clone https://github.com/jocelynpender/fna-query.git
cd fna-query
conda env create -f fna-query.yml
```

#### Usage

1. Open a terminal.
2. Prepare your query. E.g., `[[Special status::Introduced]]`
3. Run your query using:
```
cd python
python -m src.run_query --output_file_name "output_file_name.csv" --query_string "[[Query::here]]"
```

The `-m` flag tells Python to run the script `run_query.py` and **import the src module**.

#### Expected output

If your query results are extensive, the query will take some time to process. Please be patient. 

##### Option A: Taxa names only (i.e., query does not include ? parameter)
E.g., `[[Illustrator::+]][[Illustration::Present]]`

`python -m src.run_query --output_file_name "illustrated_taxa.csv" --query_string "[[Illustrator::+]][[Illustration::Present]]"`

See

##### Option B: Taxa names and properties (i.e., query includes a ? parameter)
E.g., `[[Illustrator::+]][[Illustration::Present]]|?Taxon family`

`python -m src.run_query --output_file_name "illustrated_taxa_taxon_family.csv" --query_string "[[Illustrator::+]][[Illustration::Present]]|?Taxon family"`

See

#### Run a demo query

Don't know what to query? See the demo queries here:
https://github.com/jocelynpender/fna-query/tree/master/python/demo_queries


## Getting help

Contact me at jocelyn.pender@canada.ca for support.

### Bug reports

Please leave your bug reports here: 
https://github.com/jocelynpender/fna-query/issues

## Resources

### Dependency documentation

Read more about the [https://cran.r-project.org/web/packages/WikipediR/WikipediR.pdf](WikipediR package for R). 
Read more about the [https://mwclient.readthedocs.io/en/latest/index.html](mwclient for Python).

### Merging Multiple CSV Files
Sometimes you'll need to batch the API return results. Here is an [https://github.com/jocelynpender/fna-query/blob/master/R/src/merge.R](R script for merging multiple CSV files).

**TODO:**
improve inline documentation in my script (R & Python): e.g, what are properties_texts???
