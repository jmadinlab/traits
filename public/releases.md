Releases ensure that ongoing changes to the database do not disrupt analyses. A release is a static snapshot of the database, that can correspond with a major change (that may effect compatability with older releases), minor change (data updates for traits or new trait releases) of patches (e.g., data error fixes) (see [Sementic Versioning](http://semver.org) for details). Major releases are available below as well as at Figshare in order to ensure the longevity of the data beyond the life of the Coral Trait Database. Releases are compressed folders containing two files: the actual data and the associated resources.

You can access release data directly for analyses (e.g., using R, see <a href="/download">Download</a> for details) using a variant of the .csv, /resources.csv or .zip formats as follows. However, be aware that you are loading the entire database release, which might take some time, and so it might be better to download a copy locally.

- <https://coraltraits.org/releases/ctdb_0.1.0.zip> returns the zipped folder with both data and resource files.
- <https://coraltraits.org/releases/ctdb_0.1.0.csv> returns the data in CSV format.
- <https://coraltraits.org/releases/ctdb_0.1.0/resources.csv> returns the resources corresponding with the data in CSV format.
