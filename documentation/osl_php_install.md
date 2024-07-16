# osl\_php\_install
This resource is installs PHP packages. It also adds an ini file to set the timezone to UTC and installs phpcheck and phpshow by default.

## Actions
* `:install` - Default action. Installs the given packages using the given properties.

## Properties

|  Name            |  Type           |  Default    |  Description                                     |  Required?  |
| :--------------- | :-------------: | :---------: | :----------------------------------------------- | :---------- |
| composer_version | String          | 2.2.18      | Version of Composer to install.                  | false       |
| directives       | Hash            | `{}`        | Directives to pass to `php_install` resource for ini configuration. | false       |
| opcache_conf     | Hash            | `{}`<br><br>Options in `osl_php_opcache_conf` helper are added by default. Any options set in this property override duplicates in the helper. | Configuration to add to a `10-opcache.ini` file. | false       |
| packages         | Array           | `[]`<br><br>If both `packages` and `php_packages` are empty, the `osl_php_installation_packages_without_prefixes` helper determines what is installed. | Full names of specific packages to install. The primary PHP and PEAR packages will be installed automatically, so they don't need to be specified here. | false       |
| php_packages     | Array           | `[]`<br><br>If both `packages` and `php_packages` are empty, the `osl_php_installation_packages_without_prefixes` helper determines what is installed. | Names of packages that should be installed with prefixed names (`phpX.X-` or `phpX.Xu-`), specified without the prefixes. The resource will add the appropriate prefixes to these names before installing the packages. | false       |
| use_composer     | `[true, false]` | false       | Whether to install Composer.                     | false       |
| use_opcache      | `[true, false]` | false       | Whether to install and configure OPcache.        | false       |
| version          | String          | `nil`<br><br>When `nil`, the `php_version` helper determines what version is installed. Leave as `nil` to install from system packages. | PHP version to install.                          | false       |

## Examples

Install `php`, `php-devel`, `php-cli`, and `php-pear`.
```ruby
osl_php_install 'default'
```

Install `php-fpm`, `php-gd`, `php`, and `php-pear`.
```ruby
osl_php_install 'example' do
  php_packages %w(fpm gd)
end
```

Install `php`, `php-devel`, `php-cli`, `php-pear`, and `php-opcache`, and add `opcache.enable_cli=true` and `opcache.memory_consumption=512` to the `10-opcache.ini` file.
```ruby
options = {
  'opcache.enable_cli' => true,
  'opcache.memory_consumption' => 512
}
osl_php_install 'example' do
  version '8.1'
  use_opcache true
  opcache_conf options
end
```

Install `php`, `php-fpm`, and `php-pear`.
```ruby
osl_php_install 'example' do
  version '8.1'
  php_packages %w(fpm)
end
```

Install `php`, `php-fpm`, `php-cli`, and `php-pear`.
```ruby
osl_php_install 'example' do
  version '7.1'
  php_packages %w(fpm cli)
end
```
