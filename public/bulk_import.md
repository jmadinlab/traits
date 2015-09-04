A spreadsheet import is the fastest way to get data into the database. The import function accepts csv-formatted spreadsheets and runs a number of tests to make sure your data fit the database correctly (note that you can export csv-formatted files from Excel using "Save as..."). Any errors will reject the entire import and the system will attempt to tell you where the errors occur, so you can fix these errors and try the import again.</p>

The spreadsheet you import must have a header with *at least* the following column names:

    observation_id, access, user_id, specie_id, location_id, resource_id, trait_id, standard_id, methodology_id, value, value_type, precision, precision_type, precision_upper, replicates, notes

`specie_name` and `trait_name` can be included instead of `specie_id` and `trait_id`, respectively (or you can include both ids and names). Having the names can be useful for navigating large datasets. These names must reflect the database names exactly, and so best to copy and paste names directly from the database.

`resource_id` is reserved for the original data resource (i.e., the paper that reports the original collection of the measurement).  You can credit papers that compiled large datasets from the literature by adding a column named `resource_secondary_id`. `resource_id` and `resource_secondary_id` may be substituted with `resource_doi` and `resource_secondary_doi`, respectively (the doi should start with "10", not "doi:"). The resource will automatically be added using Crossref if the doi is not in the database.

`user_id` must by your own database user id (i.e., you cannot import data for other people). You can find your user id by clicking on your name in the top right corner and selecting "My Observations".

Copy and paste the above headers into a text file and save as `import_trait_author_year.csv`, where author and year correspond with the resource (paper). Alternatively, download a [CSV](/import_template_author_year.csv) or [Excel](/import_template_author_year.xlsx) template.

### Observation-level data

    [FIX] The first six columns are associated with the observation. observation_id is an unique integer that groups a set of measurements into one observation. access is a boolean value indicating if the observation should be accessible (0 denotes private and 1 denotes public). 
    user_id is the unique ID (integer) of the person entering the data. specie_id or specie_name is the unique ID or name of the coral species of which the observation was taken. location_id is the unique ID of the location where the observation took place. resource_id is the unique ID of the resource (paper) where the observation was published. resource_id can be empty for unpublished data, in which case access must be private (0) until the data are published and the published resource is entered. resource_secondary_id can be optionally included when entering data from a paper that compiled data from other resources.

`observation_id` is an unique integer that groups a set of measurements into one observation. In [example 1](#example1) below, the first four rows belong to the same observation of a coral.

`access` is a boolean value (0 or 1) indicating if the observation should be accessible (0 denotes private and 1 denotes public). Assess can be changed after an import at any time from your observations page. In [example 1](#example1), the data are public.

`user_id` is the unique ID (integer) of the person uploading the data. This person will have control over the data and may be contacted about the data if need be. Your user ID can be found at the top of the "My observations" page that can be accessed from the top right menu.

`specie_id` is the unique ID (integer) of the coral species of which the observation was taken. IDs occur in grey to the left of [species](/species) or at the top of a given coral's observations page. In [example 1](#example1), specie_id 37 is *[Acropora cervicornis](/species/37)*.

`location_id` is the unique ID (integer) of the location where the observation took place. IDs occur in grey to the left of [locations](/locations) or at the top of a given location's observations page. The location ID 248 in [example 1](#example1) is [Buck Island, St. Croix](/locations/248).

`resource_id` is the unique ID (integer) of the resource (paper) where the observation was published. IDs occur in grey to the left of [resources](/resources) or at the top of a given resource's observations page. In [example 1](#example1), resource 590 is [Gladfelter (1982)](/resources/590). resource_id can be empty for unpublished data, in which case access must be private (0) until the data are published and the published resource is entered.
  
> **Warning** All measurements corresponding to the same observation should have exactly the same observation-level data. Use copy and paste to avoid making errors.

*[Top](#)*

### Measurement-level data

    [FIX] Columns 7 to 16 are associated with measurement-level data. All measurements corresponding to the same observation should have exactly the same observation-level data.  trait_id or trait_name is the unique ID (integer) or name of the coral trait, species-level characteristic or contextual “trait” that was measured. standard_id is the unique ID of the standard (measurement unit) that was used to measure the trait. methodology_id is the unique ID of the methodology used to measure the trait. value is the actual measured value (number, text, true/false, etc.). If the value is an option of a categorical trait (e.g., growth form), then the value must exactly match the value options for the trait (e.g., massive). If the value option does not exist for a trait, it must first be added by editing the trait. value_type describes the type of value. Current options are: raw_value for a direct measurement, mean if the value represents the mean of more than one value, median if the value represents the median of more than one value, maximum if the value represents the maximum of more than one value, minimum if the value represents the minimum of more than one value, model_derived if the value is derived from a model, expert_opinion if the actual value has not been measured directly, but an expert feels confident of the value, perhaps based on phylogenetic relatedness or an indirect observation, group_opinion if the actual value has not been measured directly, but a group of experts feel confident of the value. precision is the level of variation associated with the value if it is made up from more than one measurement (e.g., mean). precision_type is the kind of variation that the precision estimate (above) corresponds with. Current options are standard_error, standard_deviation, 95_ci and range. precision_upper is used to capture the maximum (upper) value if range is used (above). replicates is the number of measurement (replicates) that were used to calculate the value. Leave this field blank if equal to one (e.g., a raw_value). notes is an optional field for reporting useful information about how the measurement was made.

`trait_id` is the unique ID (integer) of the coral trait, species-level characteristic or contextual "trait" that was measured. IDs occur in grey to the left of [traits](/traits) or at the top of a given trait's observations page.

`standard_id` is the unique ID (integer) of the standard (unit) that was used to measure the trait. IDs occur in grey to the left of [standards](/standards).

`methodology_id` is the unique ID (integer) of the methodology used to measure the trait. IDs occur in grey to the left of [methodologies](/methodologies) or at the top of a given methodology's observations page.

`value` is the actual measured value (number, text, true/false, etc.). If the value is an option of a categorical trait (e.g., growth form), then the value must exactly match the value options for the trait (e.g., massive). If the value option does not exist for a trait, can you use an existing option? If not, then value options can be added by editing the trait. We strongly suggest that you have an [Editor](/editors) add the option for you.

`value_type` describes the type of value. Options are:

- `raw_value` for a direct measurement.
- `mean` if the value represents the mean of more than one value. Also enter precision estimates and the number of measurements that the value represents.
- `median` if the value represents the median of more than one value. Also enter precision estimates and the number of measurements that the value represents.
- `maximum` if the value represents the maximum of more than one value.
- `minimum` if the value represents the minimum of more than one value.
- `model_derived` if the value is derived from a model. Precision should be included and the resource (paper) should clearly explain how the value was derived in a reproducible way.
- `expert_opinion` if the actual value has not been measured directly, but an expert feels confident of the value, perhaps based on phylogenetic relatedness or an indirect observation.
- `group_opinion` if the actual value has not been measured directly, but a group of experts feel confident of the value.

`precision` is the level of variation associated with the `value` if it is made up from more than one measurement (e.g., mean).

`precision_type` is the kind of variation that the `precision` estimate (above) corresponds with. Options are:

- `standard_error`
- `standard_deviation`
- `95_ci`
- `range`

`precision_upper` is used to capture the maximum (upper) value if range is used (above).

`replicates` is the number of measurement (replicates) that were used to calculate the `value`.  Leave this field blank if equal to one (e.g., a raw_value).

`notes` is an optional field for reporting useful information about how the measurement was made.

*[Top](#)*

### Example import 1

[Screenshot import 1](/images/import_example1.png)

The screenshot linked to above is part of an import spreadsheet for coral [skeletal densities](/traits/61) of *[Acropora cervicornis](/species/37)* in a study on [Buck Island, St. Croix](/locations/248) ([Gladfelter 1982](/resources/590)). Density measurements were taken using a [Kobe porosimeter](/methodologies/5). Context for skeletal density measurements include the [part of the corallite](/traits/159) (e.g., calyx), [distance from tip](/traits/157) of branch, and the [water depth](/traits/143) where corals were collected.

*[Top](#)*

