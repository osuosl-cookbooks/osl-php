# osl-php Cookbook

Attributes
----------
* `node['osl-php']['use_ius']` - Use PHP packages from [IUS Community](https://ius.io/) repositories when true. Defaults to false.
* `node['osl-php']['packages']` - PHP packages to install that don't begin with a PHP prefix ("php-", "php56u-", "php71u-", etc.). Prefixed packages should be put in the `php_packages` attribute instead.
* `node['osl-php']['php_packages']` - PHP packages to install with prefixed names ("php-", "php56u-", "php71u-", etc.), specified without these prefixes. Packages with this naming convention should be specified here instead of the `packages` attribute. See Usage for details.

Usage
-----
### osl-php::default
Installs PHP packages (see below), updates upstream's default pear channels, and creates a `php.ini` configuration.

### osl-php::packages
The packages recipe makes use of the three attributes described above (`use_ius`, `packages`, and `php_packages`).
`use_ius` should be set to true or false depending on whether PHP packages from IUS Community repos should be used.

The primary PHP package and pear package are installed by this recipe automatically, and do not have to be specified in attributes. The `packages` and `php_packages` attributes are for additional PHP packages.

Most PHP packages have a prefix in their names, like "php-memcached".
Packages from IUS have versioned prefixes, like "php56u-memcached" or "php71u-memcached".
Packages that have these prefixes should be added to `php_packages` without the prefix.
Instead of adding "php-memcached" or "php71u-memcached", "memcached" would be added.
The recipe will handle adding the proper prefixes, depending on `node['php']['version']` (when using IUS).

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
This is not compatible with PHP packages from IUS Community repos, so an exception will be raised if `node['osl-php']['use_ius']` is true.
