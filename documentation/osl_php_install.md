# osl\_php\_install
This resource is used to install PHP packages. It also adds an ini file to set the timezone to UTC and install phpcheck and phpshow by default.

## Actions
* `:install` - Default action. Installs the given packages using the given properties.

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
    <td align="center"><code>nil</code><br><br>When <code>nil</code>, the <code>php_version</code> helper determines what version is installed. Leave as nil to install from system packages.</td>
    <td>PHP version to install.</td>
    <td>false</td>
  </tr>
  <tr>
    <td>use_ius</td>
    <td align="center">[true, false]</td>
    <td align="center">false</td>
    <td>Whether to install from IUS (<a href='https://ius.io/'>Inline with Upstream Stable</a>) repositories. Uses IUS archive repo if the PHP version is part of the `osl_php_ius_archive_versions` helper list. This helper should be updated based on IUS's list of EOL'd packages: https://github.com/iusrepo/packaging/wiki/End-Of-Life-Dates#php</td>
    <td>false</td>
  </tr>
  <tr>
    <td>use_composer</td>
    <td align="center">[true, false]</td>
    <td align="center">false</td>
    <td>Whether to install Composer.</td>
    <td>false</td>

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

Install `php56u`, `php56u-devel`, `php56u-cli`, `php56u-pear`, and `php56u-opcache`, and add `opcache.enable_cli=true` and `opcache.memory_consumption=512` to the `10-opcache.ini` file.
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

Install `php56u`, `php56u-fpm`, and `php56u-pear`.
```ruby
osl_php_install 'example' do
  version '5.6'
  use_ius true
  php_packages %w(fpm)
end
```

Install `php71u`, `php71u-fpm`, `php71u-cli`, and `pear1`.
```ruby
osl_php_install 'example' do
  version '7.1'
  use_ius true
  php_packages %w(fpm cli)
end
```
