# osl-php Cookbook

## Resources


### osl\_php\_apc
This resource is used to install APC from the PECL channel. Not compatible with EL >= 8.

#### Actions
* `:install` - Default action. Installs APC and creates an ini file with the specified configuration.

#### Properties

<table style="width:80%">
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Default</th>
    <th>Description</th>
    <th>Required?</th>
  </tr>
  <tr>
    <td>options</td>
    <td align="center">Hash</td>
     <td align="center"><code>osl_php_apc_conf</code> helper</td>
    <td>Configuration to add to ini file.</td>
    <td>true</td>
  </tr>
</table>

### osl\_php\_ini
This resource is used to create ini files for PHP configuration.

#### Actions
* `:add` - Default action. Creates an ini file at the location specified by the name property with the configuration
  passed to the options property.
* `:remove` - Removes an ini file at the location specified by the name property.

#### Properties

<table style="width:80%">
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Default</th>
    <th>Description</th>
    <th>Required?</th>
  </tr>
  <tr>
    <td>path</td>
    <td align="center">String</td>
     <td align="center">Name</td>
    <td>Path to place ini file.</td>
    <td>true</td>
  </tr>
  <tr>
    <td>options</td>
    <td align="center">Hash</td>
    <td align="center"><code>{}</code></td>
    <td>A hash for configuring the ini file. A basic hash with keys and values of type String will be rendered as <code>'key'='value'</code> in the file. Nesting a basic hash so the key is type String and the value is another hash will create a section with the key as the name and the value as the section contents, still in the <code>'subkey'='subvalue'</code> format.</td>
    <td>true</td>
  </tr>
  <tr>
    <td>mode</td>
    <td align="center">String</td>
    <td align="center">'0644'</td>
    <td>Unix file mode of ini file.</td>
    <td>false</td>
  </tr>
</table>

