> You need to request to become a contributor before importing data <coraltraits@gmail.com>

A spreadsheet import is the fastest way to get data into the database. The import function accepts csv-formatted spreadsheets and runs a number of tests to make sure your data fit the database correctly (note that you can export csv-formatted files from Excel using "Save as..."). Any errors will reject the entire import and the system will attempt to tell you where the errors occur, so you can fix these errors and try the import again.

The spreadsheet you import must have a header with *at least* the following column names:

    observation_id, access, user_id, specie_id, location_id, resource_id, trait_id, standard_id, methodology_id, value, value_type, precision, precision_type, precision_upper, replicates, notes

`specie_name` and `trait_name` can be included instead of `specie_id` and `trait_id`, respectively (or you can include both ids and names). Having the names can be useful for navigating large datasets. These names must reflect the database names exactly, and so best to copy and paste names directly from the database.

`resource_id` is reserved for the original data resource (i.e., the paper that reports the original collection of the measurement).  You can credit papers that compiled large datasets from the literature by adding a column named `resource_secondary_id`. `resource_id` and `resource_secondary_id` may be substituted with `resource_doi` and `resource_secondary_doi`, respectively (the doi should start with "10", not "doi:"). The resource will automatically be added using Crossref if the doi is not in the database.

`user_id` must by your own database user id (i.e., you cannot import data for other people). You can find your user id by clicking on your name in the top right corner and selecting "My Observations".

Copy and paste the above headers into a text file and save as `import_trait_author_year.csv`, where author and year correspond with the resource (paper). Alternatively, download a [CSV](/import_template_author_year.csv) or [Excel](/import_template_author_year.xlsx) template.

### Observation-level data

The first six required columns are associated with the observation.

`observation_id` is an unique integer that groups a set of measurements into one observation. In the example below, the first two rows belong to the same observation of a coral.

`access` is a boolean value indicating if the observation should be accessible (0 denotes private and 1 denotes public). In the example below, the data are public.

`user_id` is the unique ID (integer) of the person entering the data. 

`specie_id` and/or `specie_name` is the unique ID or name of the coral species of which the observation was taken. IDs occur in grey to the left of [species](/species) or at the top of a given coral specie's observation page. In the example, specie_id 206 is *[Agaricia tenuifolia](/species/206)*.

`location_id` is the unique ID of the location where the observation took place. The location_id 374 in the example is [Turneffe Atoll, Belize](/locations/374).

`resource_id` is the unique ID of the resource (paper) where the observation was published. `resource_id` can be empty for unpublished data, in which case `access` must be private (0) until the data are published and the published resource is entered. In the example the resource_id 606 is [Gleason et al. (2009)](/resources/606).

![import_example1.png](/images/import_example1_small.png)
  
*[Top](#)*

### Measurement-level data

The remaining columns are associated with measurement-level data. All measurements corresponding to the same observation should have exactly the same observation-level data. 

> **Warning** All measurements corresponding to the same observation should have exactly the same observation-level data. Use copy and paste to avoid making errors.

`trait_id` and/or `trait_name` is the unique ID (integer) or name of the coral trait, species-level characteristic or contextual "trait" that was measured. Trait IDs occur in grey to the left of [traits](/traits) or at the top of a given trait's observations page.

`standard_id` is the unique ID of the standard (measurement unit) that was used to measure the trait. 

`methodology_id` is the unique ID of the methodology used to measure the trait. 

`value` is the actual measured value (number, text, true/false, etc.). If the value is an option of a categorical trait (e.g., growth form), then the value must exactly match the value options for the trait (e.g., massive).

`value_type` describes the type of value. Current options are: 

- `raw_value` for a direct measurement, 
- `mean` if the value represents the mean of more than one value, 
- `median` if the value represents the median of more than one value, 
- `maximum` if the value represents the maximum of more than one value, 
- `minimum` if the value represents the minimum of more than one value, 
- `model_derived` if the value is derived from a model, 
- `expert_opinion` if the actual value has not been measured directly, but an expert feels confident of the value, perhaps based on phylogenetic relatedness or an indirect observation, 
- `group_opinion` if the actual value has not been measured directly, but a group of experts feel confident of the value. 

`precision` is the level of uncertainty associated with the value if it is made up from more than one measurement (e.g., mean). 

`precision_type` is the kind of uncertainty that the precision estimate (above) corresponds with. Current options are:

- `standard_error`
- `standard_deviation`
- `95_ci` 
- `range` 

`precision_upper` is used to capture the maximum (upper) value if range is used (above). 

`replicates` is the number of measurement (replicates) that were used to calculate the value. Leave this field blank if equal to one (e.g., a raw_value). 

`notes` is an optional field for reporting useful information about how the measurement was made.

*[Top](#)*

