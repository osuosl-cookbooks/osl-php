# osl\_php\_ini

This resource is used to create ini files for PHP configuration.

Adding, changing or removing an ini file runs `notify_group[osl-php restart]` at the end of the Chef run, which reloads every PHP service registered with [osl_php_web_service](osl_php_web_service.md). With nothing registered (a CLI-only host), the group does nothing.

## Actions

* `:add` - Default action. Creates an ini file at the location specified by the name property with the configuration
  passed to the options property.
* `:remove` - Removes an ini file at the location specified by the name property.

## Properties

|  Name        |  Type  |  Default  |  Description                 |  Required?  |
| :----------- | :----: | :-------: | :----------------------------| :---------- |
| mode         | String | '0644'    | Unix file mode of ini file.  | false       |
| options      | Hash   | `{}`      | A hash for configuring the ini file. A basic hash with keys and values of type String will be rendered as `'key'='value'` in the file. Nesting a basic hash so the key is type String and the value is another hash will create a section with the key as the name and the value as the section contents, still in the `'subkey'='subvalue'` format. | true        |
| path         | String | Name      | Path to place ini file.      | true        |
| php\_version | String |           | When set, places the ini file in the versioned Remi PHP config directory (`/etc/opt/remi/php{version}/php.d/`) instead of the default `/etc/php.d/`. Value should be a version string like `'8.4'`. | false       |
| config\_dir  | String |           | Directory for the ini file, overriding both the default and `php_version`. PHP only reads it if it is in the scan path, for example through `PHP_INI_SCAN_DIR`. | false       |
