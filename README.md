# osl-php Cookbook

Attributes
----------
* `node['osl-php']['ius_archive_versions']` - A list tracking versions of PHP that have moved into IUS's archive repo. The recipe should be updated when new versions on this list reach EOL: https://ius.io/LifeCycle/#php
* `node['osl-php']['use_ius']` - Use PHP packages from [IUS Community](https://ius.io/) repositories when true. Defaults
  to false.
* `node['osl-php']['use_opcache']` - Use [Zend Opcache](http://files.zend.com/help/Zend-Server/content/working_with_opcache.htm)
  to cache compiled PHP scritps. Defaults to false.
* `node['osl-php']['packages']` - PHP packages to install that don't begin with a PHP prefix ("php-", "php56u-",
  "php71u-", etc.). Prefixed packages should be put in the `php_packages` attribute instead.
* `node['osl-php']['php_packages']` - PHP packages to install with prefixed names ("php-", "php56u-", "php71u-", etc.),
  specified without these prefixes. Packages with this naming convention should be specified here instead of the
  `packages` attribute. See Usage for details.

Usage
-----
### osl-php::default
Installs PHP packages (see below), updates upstream's default pear channels, and creates a `php.ini` configuration.
This recipe will also install Zend Opcache if`use_opcache` is true, and the php is compatible (5.5 or greater).
Use the `node['osl-php']['opcache']` hash to set parameters for Zend Opcache.

### osl-php::opcache
Adds Opcache package to `node['osl-php']['php_packages']` and configures Zend Opcache's ini. Don't include this recipe
directly, it gets included by the default recipe. `use_opcache` should be set to true to enable Zend Opcache.
If true, php must be v5.5 or greater. Include `osl-php::default` after setting the proper attributes.

### osl-php::apc
Installs APC using the hash `node['osl-php']['apc']` to configure it's ini in the exact same manner as opcache.
This is not compatible with PHP packages from IUS Community repos, so an exception will be raised if
`node['osl-php']['use_ius']` is true.

### osl-php::packages
The packages recipe uses three of the four attributes described above (`use_ius`, `packages`, and `php_packages`).
`use_ius` should be set to true or false depending on whether PHP packages from IUS Community repos should be used.

The primary PHP package and pear package are installed by this recipe automatically, and do not have to be specified in
attributes. The `packages` and `php_packages` attributes are for additional PHP packages.

Most PHP packages have a prefix in their names, like "php-memcached".  Packages from IUS have versioned prefixes, like
"php56u-memcached" or "php71u-memcached".  Packages that have these prefixes should be added to `php_packages` without
the prefix.  Instead of adding "php-memcached" or "php71u-memcached", "memcached" would be added.  The recipe will
handle adding the proper prefixes, depending on `node['php']['version']` (when using IUS).

PHP-related packages that don't have this prefix should be placed in the `packages` attribute.

#### Examples

```ruby
node.default['osl-php']['use_ius'] = false
node.default['osl-php']['php_packages'] = %w(devel cli)
include_recipe 'osl-php::packages'
```
will install `php`, `php-devel`, `php-cli`, and `php-pear`.

```ruby
node.default['php']['version'] = '5.6'
node.default['osl-php']['use_ius'] = true
node.default['osl-php']['use_opcache'] = true
node.default['osl-php']['opcache']['opcache.enable_cli'] = 'true'
node.default['osl-php']['opcache']['opcache.memory_consumption'] = 512
include_recipe 'osl-php'
```
will install `php56u`, `php56u-opcache`, and add `opcache.enable_cli=true`, `opcache.memory_consumption=512` to the
opcache's ini file.

```ruby
node.default['php']['version'] = '5.6'
node.default['osl-php']['use_ius'] = true
node.default['osl-php']['php_packages'] = %w(devel cli)
include_recipe 'osl-php::packages'
```
will install `php56u`, `php56u-devel`, `php56u-cli`, and `php56u-pear`.

```ruby
node.default['php']['version'] = '7.1'
node.default['osl-php']['use_ius'] = true
node.default['osl-php']['php_packages'] = %w(devel cli)
include_recipe 'osl-php::packages'
```
will install `php71u`, `php71u-devel`, `php71u-cli`, and `pear1u`.

### osl-php::apc
Installs APC.
This is not compatible with PHP packages from IUS Community repos, so an exception will be raised if
`node['osl-php']['use_ius']` is true.

## Resources

### osl\_php\_install
This resource is used to install PHP packages. It will also add an ini file to set the timezone to UTC and install phpcheck and phpshow by default.

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
     <td align="center">`[]`; if both `packages` and `php_packages` are empty, the`php_installation_packages` helper determines what is installed.</td>
    <td>Full names of specific packages to install. The primary PHP and PEAR packages will be installed automatically, so they don't need to be specified here.</td>
    <td>false</td>
  </tr>
  <tr>
    <td>php_packages</td>
    <td align="center">Array</td>
    <td align="center">`[]`; if both `packages` and `php_packages` are empty, the `php_installation_packages` helper determines what is installed.</td>
    <td>List of names of packages that should be installed with prefixed names(`phpX.X-` or `phpX.Xu-`), specified without the prefixes. The resource will add the appropriate prefixes to these names and install the packages.</td>
    <td>false</td>
  </tr>
  <tr>
    <td>version</td>
    <td align="center">String</td>
    <td align="center">`nil`; when `nil`, the `php_version()` helper determines what version is installed.</td>
    <td>PHP version to install.</td>
    <td>false</td>
  </tr>
  <tr>
    <td>use_ius</td>
    <td align="center">[true, false]</td>
    <td align="center">false</td>
    <td>Whether to install from IUS (Inline with Upstream Stable) repositories.</td>
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
    <td>Whether to install PHP OPcache (and configure Zend OPcache with an ini file).</td>
    <td>false</td>
  </tr>
  <tr>
    <td>opcache_conf</td>
    <td align="center">Hash</td>
    <td align="center">{}</td>
    <td>Configuration to add to a `10-opcache` ini file. The options in the `opcache_conf` helper are added by default. Any options set in this property override repeats in the helper.</td>
    <td>false</td>
  </tr>
</table>

### osl\_php\_ini
This resource is used to create ini files for PHP configuration.

#### Actions
* `:create` - Default action. Creates an ini file at the location specified by the name property with the configuration
  passed to the options property, while applying other properties.
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
    <td>Path to place ini file</td>
    <td>true</td>
  </tr>
  <tr>
    <td>options</td>
    <td align="center">Hash</td>
    <td align="center">{}</td>
    <td>A hash for configuring the ini file. A basic hash with keys and values of type string will render the file with 'key'='value'. Nesting a basic hash so the key is string and the value is another hash will create a section with the string as the name, and the hash value will render with 'key'='value'</td>
    <td>true</td>
  </tr>
  <tr>
    <td>mode</td>
    <td align="center">String</td>
    <td align="center">'0644'</td>
    <td>Unix file mode of ini file</td>
    <td>false</td>
  </tr>
</table>
