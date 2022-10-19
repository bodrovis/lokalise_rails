# Changelog

## 4.0.0 (27-Jan-22)

* File exporting is now multi-threaded as Lokalise API started to support parallel requests since January 2022
* Test with Ruby 3.1

## 3.0.0 (14-Oct-21)

This is a major re-write of this gem. The actual import/export functionality was extracted to a separate gem called [lokalise_manager](https://github.com/bodrovis/lokalise_manager) that you can use to run your tasks programmatically from *any* Ruby scripts (powered or not powered by Rails). LokaliseRails now has only the Rails-related logic (even though it should probably work with other frameworks as well).

* **Breaking change:** the global config class is renamed therefore update your `config/lokalise_rails.rb` file to look like this:

```ruby
LokaliseRails::GlobalConfig.config do |c|
  # ...your configuration options provided as before...
end
```

* **Breaking change**: the `branch` config option now has `""` set as default value (it was `"master"` previously). Therefore, you might need to explicitly state which branch to use now:

```ruby
LokaliseRails::GlobalConfig.config do |c|
  c.branch = "master"
end
```

* **Breaking change**: to run your task prommatically, use a new approach:

```ruby
LokaliseManager.importer(optional_config, global_config_object).import!

LokaliseManager.exporter(optional_config, global_config_object).export!
```

* Please check [this document section](https://github.com/bodrovis/lokalise_rails#running-tasks-programmatically) to learn more about running tasks programmatically. This change doesn't have any effect on you if you're using only Rake tasks to import/export files.
* No need to say `require 'lokalise_rails` in your `lokalise_rails.rb` config file anymore.

## 2.0.0 (19-Aug-21)

* Add exponential backoff mechanism for file imports to comply with the upcoming API changes ("rate limiting"), see below for more details.
* Add `max_retries_import` option with a default value of `5`.

## 2.0.0.rc1 (12-Aug-21)

* **Lokalise is introducing API rate limiting.** Access to all endpoints will be limited to 6 requests per second from 14 September, 2021. This limit is applied per API token and per IP address. If you exceed the limit, a 429 HTTP status code will be returned and a `Lokalise::Error::TooManyRequests` exception will be raised. Therefore, to overcome this issue LokaliseRails is introducing an exponential backoff mechanism for file exports. Why? Because if you have, say, 10 translation files, we'll have to send 10 separate API requests which will probably mean exceeding the limit (this is not the case with importing as we're always receiving a single archive). Thus, if the HTTP status code 429 was received, we'll do the following:

```ruby
sleep 2 ** retries
retries += 1
```

* If the maximum number of retries has been reached LokaliseRails will re-raise the `Lokalise::Error::TooManyRequests` error and give up. By default, the maximum number of retries is set to `5` but you can control it using the `max_retries_export` option.
* Enabled compression for the API client.

## 1.4.0 (29-Jun-21)

* Re-worked exception handling. Now when something goes wrong during the import or export process, this gem will re-raise all such errors (previously it just printed out some errors to the `$stdout`). If you run a Rake task, it will exit with a status code `1` and the actual error message. If you run a task programattically, you'll get an exception.
* Dropped support for Ruby 2.5
* Test against Ruby 3

## 1.3.1 (01-Apr-21)

* A bit better exception handling
* Update dependencies

## 1.3.0 (02-Feb-21)

* Use ruby-lokalise-api v3

## 1.2.0 (11-Nov-20)

* New option `translations_loader`
* New option `translations_converter`
* New option `lang_iso_inferer`

## 1.1.0 (23-Oct-20)

* New option `branch`
* New option `timeouts`
* New method `.reset_api_client!` for the task definitions

## 1.0.1 (14-Oct-20)

* Minor bug fixes and spec updates

## 1.0.0 (01-Oct-20)

* Added export feature
* More convenient configuration and additional options
* Other major enhancements

## 0.2.0 (26-Sep-20)

* Allow to override options properly

## 0.1.0 (26-Sep-20)

* Initial (proper) release
