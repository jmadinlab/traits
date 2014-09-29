# Downloading data
***

> There are a number of ways to extract data from the database

### Website downloads

Data can be directly downloaded for one or more [coral species](/corals), [traits](/traits), [locations](/locations), [resources](/resources) or [methodologies](/methodologies) by using the checkboxes on the corresponding pages and clicking <label class="label label-success">Download</label>. A zipped folder is downloaded containing two files: 

1. A csv-formatted data file containing all publicly avaiable data for your selection/s, which includes contextual data by default. You can choose to exclude contextual data, include taxonomic detail and/or retrieve global estimates only.
2. A csv-formatted resource file containing all the resources (papers) that correspond with the data. You are expected to cite the data using these resources correctly. 

> Files in csv-format can be opened in spreadsheet applications (e.g., OpenOffice, Excel, Numbers) or loaded into R using `read.csv()`.

### Controlled downloads

Every data page in the database can be loaded in four formats: html, csv, resources or zip. For example, for traits:

- <http://coraltraits.org/traits/105> returns the html page for trait_id 105 (i.e., growth form).
- <http://coraltraits.org/traits/105.csv> returns the growth form data in CSV format.
- <http://coraltraits.org/traits/105/resources.csv> returns the resources corresponding with the data.
- <http://coraltraits.org/traits/105.zip> returns the zipped folder with both data and resource files.

Similarly for corals:

- <http://coraltraits.org/corals/80> returns the html page for coral_id 80 (*Acropora hyacinthus*).
- <http://coraltraits.org/corals/80.csv> returns *Acropora hyacinthus* data in CSV format.
- <http://coraltraits.org/corals/80/resources.csv> returns the resource list corresponding with the data.
- <http://coraltraits.org/corals/80.zip> returns the zipped folder with both data and resource files.

And so on for locations, resources and methodologies.

To control the download of contextual data, taxonomic detail and/or global estimates, append the desired combination to the web address. By default, `taxonomic` detail is "off", `contextual` data is "on", and `global` estimates only is "off". The following examples demonstrate how to use web address syntax to control your download:

- <http://coraltraits.org/locations/132.csv?taxonomy=on> returns taxonomic detail, including morphological and molecular family and synonyms.
- <http://coraltraits.org/locations/132.csv?taxonomy=on&contextual=off> returns taxonomic detail and no contextual data.
- <http://coraltraits.org/locations/132.csv?contextual=off> returns no contextual data (with defaults for taxonomic detail and global estimates).
- <http://coraltraits.org/locations/132.csv?taxonomy=on&contextual=off&global=on> returns taxonomic detail, no contextual data, and only global estimates of traits.

### Direct R imports

Using web address syntax described above, you can pipe up-to-date data directly into R from the database using the `read.csv()` function. The following R code will directly import all publicly available growth form data directly into R.

    dat <- read.csv("http://coraltraits.org/traits/105.csv", as.is=TRUE)

(`as.is=TRUE` prevents R from converting columns into unwanted data types, like factors)

The benefits of directly importing data into R are that you always have the most up-to-date version, and you don't have to keep local copies. If you were actively adding data to the database, and wanted your analysis to reflect the current state of your work, you might use the R import functionality.

Currently there is no bulk import for R. That is, you can only import one trait, coral, etc. based on an id at a time. One workaround is to create a list of trait or coral ids (which never change) and either use a loop or an `apply` function to iteratively download and combine the data you require for your analysis.

*[Top](#)*

# Reshaping data downloads

Data is downloaded as a table in which the leading columns contain observation-level data and the tailing columns contain measurement-level data. Downloading species by trait matrices is not supported for two reasons.  First, there are many possible ways to aggregate such a matrix and so it's better to have control over this yourself.  Second, the table download retains essential metadata such as units, resources and data contributors.</p>

To convert a downloaded table into a species by trait matrix, you can use R packages like `reshape2`. Once this package is loaded, you can use the `acast` function to create your desired data structure. Initially, you might use:

    acast(dat, coral_name~trait_name, value.var="value", fun.aggregate=function(x) {x[1]})

Which grabs the first measurement value for a species and is suitable for traits with one value (e.g., global estimates). How you aggregate traits with many values will depend on the trait. 

    acast(dat, coral~trait_name, value.var="value", fun.aggregate=function(x) {mean(x)})

Will create a species by trait matrix with mean values for each species, but this will not work if you have non-numeric traits in your dataset (e.g., growth form or reproductive mode). Therefore, the `fun.aggregate` method needs to be manipulated using logical conditions to get the data structure you want (e.g., what to do if a species trait has more than one value, or what to do if a species trait has more than one value and thosee values are characters).  

Below is a generic example that returns mean values for numeric trait values and the first value for character trait values in cases where there are more than one value for a species by trait combination.

    # Load the "reshape2" package for R.  This package must initially be downloaded from CRAN
    library(reshape2)

    # Load your csv file downloaded from the trait database
    data_raw <- read.csv("data/data_20140224.csv", as.is=TRUE)

    # Develop your aggregation rules function for the "acast" function
    my_aggregate_rules <- function(x) {
      if (length(x) > 1) {               # Does a species by trait combination have more than 1 value?
        x <- type.convert(x, as.is=TRUE)
        if (is.character(x)) {
          return(x[1])                   # If values are strings (characters), then return the first value
        } else {
          return(as.character(mean(x)))  # If values are numbers, then return the mean (converted back to character)
        }
      } else {
        return(x)                        # If a species by trait combination has 1 value, then just return that value 
      }
    }

    # Reshape your data using "acast".  Fill gaps with NAs
    data_reshaped <- acast(data_raw, coral_name~trait_name, value.var="value", fun.aggregate=my_aggregate_rules, fill="")

    data_reshaped[data_reshaped == ""] <- NA

    # If desired, convert the reshaped data into a data frame for analysis in R
    data_final <- data.frame(data_reshaped, stringsAsFactors=FALSE)

    # Note that all variables are still character-formatted.  Use as.numeric() and as.factor() accordingly.  For example,
    data_final$Corallite.maximum.width <- as.numeric(data_final$Corallite.maximum.width)
    data_final$Red.list.category <- as.factor(data_final$Red.list.category)

*[Top](#)*
