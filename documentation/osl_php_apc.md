# osl\_php\_apc
This resource is used to install APC from the PECL channel. Not compatible with EL >= 8.

## Actions
* `:install` - Default action. Installs APC and creates an ini file with the specified configuration.

## Properties

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
