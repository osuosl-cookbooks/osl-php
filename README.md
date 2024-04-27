# osl-php Cookbook

## Resources

### osl\_php\_install
This resource is used to install PHP packages. It also adds an ini file to set the timezone to UTC and install phpcheck and phpshow by default.

#### Actions
* `:install` - Default action. Installs the given packages using the given properties.

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
    <td>packages</td>
    <td align="center">Array</td>
    <td align="center"><code>[]</code><br><br>If both <code>packages</code> and <code>php_packages</code> are empty, the <code>php_installation_packages</code> helper determines what is installed.</td>
    <td>Full names of specific packages to install. The primary PHP and PEAR packages will be installed automatically, so they don't need to be specified here.</td>
    <td>false</td>
  </tr>
  <tr>
    <td>php_packages</td>
    <td align="center">Array</td>
    <td align="center"><code>[]</code><br><br>If both <code>packages</code> and <code>php_packages</code> are empty, the <code>php_installation_packages</code> helper determines what is installed.</td>
    <td>List of names of packages that should be installed with prefixed names (<code>phpX.X-</code> or <code>phpX.Xu-</code>), specified without the prefixes. The resource will add the appropriate prefixes to these names and install the packages.</td>
    <td>false</td>
  </tr>
  <tr>
    <td>version</td>
    <td align="center">String</td>
    <td align="center"><code>nil</code><br><br>When <code>nil</code>, the <code>php_version</code> helper determines what version is installed.</td>
    <td>PHP version to install.</td>
    <td>false</td>
  </tr>
  <tr>
    <td>use_ius</td>
    <td align="center">[true, false]</td>
    <td align="center">false</td>
    <td>Whether to install from IUS (<a href='https://ius.io/'>Inline with Upstream Stable</a>) repositories. Uses IUS archive repo if the PHP version is part of the `ius_archive_versions` helper list. This helper should be updated based on IUS's list of EOL'd packages: https://github.com/iusrepo/packaging/wiki/End-Of-Life-Dates#php</td>
    <td>false</td>
  </tr>
  <tr>
    <td>use_composer</td>
    <td align="center">[true, false]</td>
    <td align="center">false</td>
    <td>Whether to install Composer.</td>
    <td>false</td>
  </tr>
  <tr>
    <td>composer_version</td>
    <td align="center">String</td>
    <td align="center">'2.2.18'</td>
    <td>Composer version to install.</td>
    <td>false</td>
  </tr>
  <tr>
    <td>use_opcache</td>
    <td align="center">[true, false]</td>
    <td align="center">false</td>
    <td>Whether to install PHP OPcache (and configure it with an ini file). Not compatible with PHP < 5.5.</td>
    <td>false</td>
  </tr>
  <tr>
    <td>opcache_conf</td>
    <td align="center">Hash</td>
    <td align="center"><code>{}</code></td>
    <td>Configuration to add to a <code>10-opcache.ini</code> file. The options in the <code>opcache_conf</code> helper are added by default. Any options set in this property override duplicates in the helper.</td>
    <td>false</td>
  </tr>
</table>

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
     <td align="center"><code>apc_conf</code> helper</td>
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

## Usage Examples

```ruby
osl_php_install 'example' do
  php_packages %w(devel cli)
end
```
will install `php`, `php-devel`, `php-cli`, and `php-pear`.

```ruby
options = {
  'opcache.enable_cli' => true,
  'opcache.memory_consumption' => 512
}
osl_php_install 'example' do
  version '5.6'
  use_ius true
  use_opcache true
  opcache_conf options
end
```
will install `php56u` and `php56u-opcache`, and add `opcache.enable_cli=true` and `opcache.memory_consumption=512` to the `10-opcache.ini` file.

```ruby
osl_php_install 'example' do
  version '5.6'
  use_ius true
  php_packages %w(devel cli)
end
```
will install `php56u`, `php56u-devel`, `php56u-cli`, and `php56u-pear`.

```ruby
osl_php_install 'example' do
  version '7.1'
  use_ius true
  php_packages %w(devel cli)
end
```
will install `php71u`, `php71u-devel`, `php71u-cli`, and `pear1`.
