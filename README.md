# The Coral Trait Database

While figuring this out, make beta status of website more evident, to avoid any growing frustrations

## Our Mission

Following are some core values of the Coral traits database.

- Advance coral reef science through the gathering and dissemination of data resources
- Provide an open access portal providing unrestricted interactive and automated access to information about corals
- To fairly recognize those who collected original data, as well as those who compile larger data compilations
- To provide a platform for community engagement in data quality control
- To facilitate reproducible science
- To do the above with a sustainable future for the database in mind, in terms of management and longevity

## Governance

### Administrator

- Toni Mizerek

### Managerial Board

- Joshua Madin
- Andrew Baird
- Daniel Falster
- Emily Darling

For decisions requiring a vote, at least three of the Managerial Board should agree.

### [Editorial Board](http://coraltraits.org/editors)

### Taxonomy Advisory Board

- Andrew Baird
- Danwei Huang

### Technical Advisory Board

The database relies on external people with breadth of experience and technical know-how, who appreciate the subtle difficulties of managing large data compilations.

- Matt Kosnik

<!-- People to approach

- Matt Jones
- Mark Schildhauer
- John Alroy
- Ethan White
- Scott Chamberlain or Karthik Ram (ropensci)
 -->
### Database Programming

- Surendra Shrestha
- Joshua Madin

## Processes

### Scope



### [The Traits](http://coraltraits.org/traits)



### Data upload

# New corals tightly controlled


# Global estimate (location)

### Database support
o What information can be contributed? 
o What metadata are required / requested to be included with trait observations
o Protocols for contributing data that someone else collected (i.e., where contributor gleaned the data from the literature)
o Porting data published elsewhere (e.g., dryad)
o Templates for uploading
o Flag data that are duplicated / errors etc for approval

### Data sources

Will we allow unpublished data?

- Why? 
- Useful to have your data alongside other data in database. 
- More likely to contribute data at end of project

- Easier to identify duplications?

BUT 

- how much work on back end?
o Limit to cases where you are collector
o Unclear - will coral traits be primary source?

Published data

● Available in digital form with DOI 
○ port initial
○ modifications
● Available in spreadsheet, no DOI (via email)
○ spreadsheet template / upload 
● Only in print (dark data)

### Licenses

- Sci Data requires data released under CC0 to promote potential reuse. Need to ensure all sources comply.
- If allowing unpublished / private data, need to ensure one-way public access to avoid broken datasets (this the way CC0 works, once applied cannot be revoked)
Data download

### For users

- how to import into R, reshape code
- citation requirements/recommendation (original sources, database) (we can’t enforce anything, just encourage best practice, also encourage reviewers/editors to enforce this )
- recommendations for reproducible research
- how to provide feedback on errors, data quality etc (see below)
- helpdesk?

Major question: Do we make ourselves expendable or essential?, i.e. 
● commit to providing long-term access 
○ register as recognised archival location?
○ solid API
○ long-term commitment
● OR, make coraltraits.org expendenable
○ all data archived elsewhere
Version control and archiving

Of data and API

Present possible options to technical advisory board and get feedback.

Aim: to provide stable API and versioning within 3 months, i.e. before data paper is released

Option1:

Add date to database query.  So can replicate download in the future for a particular analysis.

Option 2:


### Quality control

Three levels of data review.

1. Contributor level at time of submission
2. Editorial review of user contributions by curator
3. User feedback (issues reporting) with notification back to trait editor

○ look first for approval by original curator first, then after given to next in line (curator)
○ archive discussions around this so that transparent

### Error checking

- automated tests: allowed values
- duplications: flags, does this ref already exist

### Engagement with potential users

### Strategy

### End users

- Scientists
- Reef monitoring programs (e.g., Austalian Insitute of Marine Science)

### Data distributors

Need review

- Trait bank
- RopenSci

### Recording usage

Website and data download activity are tracked using Google Analytics






# Downloading data

Data can be accessed in a number of different ways.  You can download all data for a given coral species, trait or location by checking the data you would like on the relevant page, and then clicking the Download button.  The download will include everything in the database that is publicly avaiable, which includes contextual data.  You can choose to remove the contextual data, include taxonomic detail or retrieve global estimates only.  All resources associated with data you download are packaged with the trait data, and you are expected to cite the data using these resources correctly.

You can pipe up-to-date data directly into your R code using the `read.csv()` function.  Every page in the database can be loaded as html, zip or csv.  For example, <http://coraltraits.org/traits/105> will return the html page for the trait with id=105 and <http://coraltraits.org/traits/105.csv> will return the csv (trait 105 is growth form).  The zip page pachages data with resources. For R, this would be:

    dat <- read.csv("http://coraltraits.org/traits/105.csv")

Currently there is no bulk download for R.  We suggest that you create a list of trait or coral ids (which won't change) and either use a loop or preferably an apply function to download and combine the data you require for your analysis.

### Reshaping download data

By default, the data is downloaded as a table in which the first eight columns contain observation-level data and the second eight columns contain measurement-level data.  Downloading species by trait matrices is not supported for two reasons.  First, there are many possible ways to aggregate such a matrix and so it's better to have control over this yourself.  Second, the table download retains essential metadata such as units, resources and data contributors.</p>

    <div class="row">
      <div class="col-md-12" style="overflow: scroll;">
        <pre style="width:2000px;"><code>observation_id access  enterer coral     location_name     latitude  longitude resource_id measurement_id  trait_name  standard_unit value precision precision_type  precision_upper replicates
90242   1 15  Acropora tenuis   Pioneer Bay, Orpheus Island -18.610784  146.488051  532   94682   Protein biomass mg/cm^2   4       
90242   1 15  Acropora tenuis   Pioneer Bay, Orpheus Island -18.610784  146.488051  532   94683   Depth   m   2       
90242   1 15  Acropora tenuis   Pioneer Bay, Orpheus Island -18.610784  146.488051  532   94684   Season    cat   Nov-00        
90243   1 15  Acropora tenuis   Pioneer Bay, Orpheus Island -18.610784  146.488051  532   94685   Protein biomass mg/cm^2   3.4       
90243   1 15  Acropora tenuis   Pioneer Bay, Orpheus Island -18.610784  146.488051  532   94686   Depth   m   1       
90243   1 15  Acropora tenuis   Pioneer Bay, Orpheus Island -18.610784  146.488051  532   94687   Season    cat   Nov-00        
90244   1 15  Goniastrea retiformis Pioneer Bay, Orpheus Island -18.610784  146.488051  532   94688   Protein biomass mg/cm^2   5.4       
90244   1 15  Goniastrea retiformis Pioneer Bay, Orpheus Island -18.610784  146.488051  532   94689   Depth   m   2       
90244   1 15  Goniastrea retiformis Pioneer Bay, Orpheus Island -18.610784  146.488051  532   94690   Season    cat   Nov-00        </code></pre>
      </div>
    </div>

    <p>To convert a downloaded table into a species by trait matrix, we suggest you use the <code>reshape2</code> package (or similar) in the statistical programming language R.  Once this package is loaded, use the <code>acast</code> function. Initially, you might use <code>acast(dat, coral~trait_name, value.var="value", fun.aggregate=function(x) {x[1]})</code>, which grabs the first observation/measurement value for a species and is suitable for traits with one value (e.g., Global estimates).  How you aggregate traits with many values will depend on the trait.  For example, <code>acast(dat, coral~trait_name, value.var="value", fun.aggregate=function(x) {mean(x)})</code> will create a species by trait matrix with mean values for each species, but this will not work if you have non-numeric traits in your dataset.  Therefore, the <code>fun.aggregate</code> method needs to be developed using logical conditions to get the data structure you want (e.g., what to do if a species trait has more than one value, or what to do if a species trait has more than one value and the values are characters).  Below is a generic example that returns mean values for numeric traits and the first value for character trait values in cases where there are more than one value for a species by trait combination.</p>

    <h4>Example</h4>
    <div class="row" style="overflow: scroll;">
      <div class="col-md-12">
        <pre style="width:1000px;"><code># Load the "reshape2" package for R.  This package must initially be downloaded from CRAN
library(reshape2)

# Load your csv file downloaded from the trait database
data_raw <- read.csv("data/ctdb_20140224-36.csv", as.is=TRUE)

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
data_reshaped <- acast(data_raw, coral~trait_name, value.var="value", fun.aggregate=my_aggregate_rules, fill="")

data_reshaped[data_reshaped == ""] <- NA

# If desired, convert the reshaped data into a data frame for analysis in R
data_final <- data.frame(data_reshaped, stringsAsFactors=FALSE)

# Note that all variables are still character-formatted.  Use as.numeric() and as.factor() accordingly.  For example,
data_final$Corallite.maximum.width <- as.numeric(data_final$Corallite.maximum.width)
data_final$Red.list.category <- as.factor(data_final$Red.list.category)</code></pre>
      </div>
    </div>
    
