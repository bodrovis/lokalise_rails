# Changelog

## 2.0.0 (unreleased)

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
