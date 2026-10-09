# osl\_php\_web\_service

Points a systemd unit that runs PHP for the web (php-fpm, a Remi `phpXX-php-fpm`, or `httpd` under mod_php) at osl-php's web-only ini directory, and keeps it current as PHP configuration changes.

- Writes a `php-web-ini.conf` drop-in setting `PHP_INI_SCAN_DIR=:/etc/php-web.d`. The leading `:` keeps PHP's compiled-in `php.d` first. The environment only applies when the unit starts, so a changed drop-in **restarts** the unit at the end of the Chef run.
- Registers the unit with `notify_group[osl-php restart]`, which [osl_php_ini](osl_php_ini.md) and [osl_php_install](osl_php_install.md) fire when an ini file, a PHP package or a `php.ini` directive changes. The group **reloads** the unit (USR2 for php-fpm, a graceful restart for httpd), which re-reads every ini directory without dropping requests.

Both actions are delayed to the end of the run, and Chef runs each service action at most once per run however many changes fired it.

## Registering early

Chef still runs queued delayed notifications when a run fails, so the group must have its members before any ini can change. The resource registers its unit when it converges; a resource that wraps it should also register from `after_created`, which runs at compile time:

```ruby
def after_created
  super
  osl_php_web_service_register('php-fpm')
end

action :create do
  osl_php_web_service 'php-fpm'
end
```

`osl_php_web_service_register(unit)` finds or creates `service[<unit>]` in the root run context and returns it. Notify that object, not the string `'service[<unit>]'`: in unified mode a delayed notification to a string only reaches the current custom resource's own context, which has finished converging by the time the group fires.

## Actions

* `:create` - Default action. Writes the drop-in and registers the unit.

## Properties

|  Name  |  Type  |  Default  |  Description  |  Required?  |
| :----- | :----: | :-------: | :------------ | :---------- |
| unit   | String | Name      | Systemd unit name without `.service`, for example `php-fpm`, `php84-php-fpm` or `httpd`. | true |

## Examples

```ruby
osl_php_web_service 'php-fpm'
```

```ruby
osl_php_web_service 'php84-php-fpm'
```
