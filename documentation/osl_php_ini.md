# osl\_php\_ini

This resource is used to create ini files for PHP configuration.

## Actions

* `:add` - Default action. Creates an ini file at the location specified by the name property with the configuration
  passed to the options property.
* `:remove` - Removes an ini file at the location specified by the name property.

## Properties

|  Name   |  Type  |  Default  |  Description                 |  Required?  |
| :------ | :----: | :-------: | :----------------------------| :---------- |
| path    | String | Name      | Path to place ini file.      | true        |
| options | Hash   | `{}`      | A hash for configuring the ini file. A basic hash with keys and values of type String will be rendered as `'key'='value'` in the file. Nesting a basic hash so the key is type String and the value is another hash will create a section with the key as the name and the value as the section contents, still in the `'subkey'='subvalue'` format. | true        |
| mode    | String | '0644'    | Unix file mode of ini file.  | false       |
