# LokaliseRails

[![Gem Version](https://badge.fury.io/rb/lokalise_rails.svg)](https://badge.fury.io/rb/lokalise_rails)
[![Build Status](https://travis-ci.org/bodrovis/lokalise_rails.svg?branch=master)](https://travis-ci.org/bodrovis/lokalise_rails)
[![Test Coverage](https://codecov.io/gh/bodrovis/lokalise_rails/graph/badge.svg)](https://codecov.io/gh/bodrovis/lokalise_rails)

This gem provides [Lokalise](http://lokalise.com) integration for Ruby on Rails and allows to exchange translation files easily. It relies on [ruby-lokalise-api](https://lokalise.github.io/ruby-lokalise-api) to send APIv2 requests.

## Getting started

### Requirements

This gem requires Ruby 2.5+ and Rails 5.1+. It might work with older versions of Rails though. You will also need to [setup a Lokalise account](https://app.lokalise.com/signup) and create a [translation project](https://docs.lokalise.com/en/articles/1400460-projects). Finally, you will need to generate a [read/write API token](https://docs.lokalise.com/en/articles/1929556-api-tokens) at your Lokalise profile.

### Installation

Add the gem to your `Gemfile`:

```ruby
gem 'lokalise_rails'
```

and run:

```
bundle install
rails g lokalise_rails:install
```

The latter command will generate a new config file `config/lokalise_rails.rb` looking like this:

```ruby
require 'lokalise_rails'

LokaliseRails.config do |c|
  c.api_token = ENV['LOKALISE_API_TOKEN']
  c.project_id = ENV['LOKALISE_PROJECT_ID']

  # ...other options
end
```

You have to provide `api_token` and `project_id` to proceed. `project_id` can be found in your Lokalise project settings.

[Other options can be customized as well (see below)](https://github.com/bodrovis/lokalise_rails#import-settings) but they have sensible defaults.

## Importing translations from Lokalise

To import translations from the specified Lokalise project to your Rails app, run the following command:

```
rails lokalise_rails:import
```

Please note that any duplicating files inside the `locales` directory (or any other directory that you've specified in the options) will be overwritten! You may enable [safe mode](https://github.com/bodrovis/lokalise_rails#import-settings) to check whether the folder is empty or not.

## Exporting translations to Lokalise

To export translations from your Rails app to the specified Lokalise project, run the following command:

```
rails lokalise_rails:export
```

## Running tasks programmatically

You can also run the import and export tasks from the Rails app:

```ruby
require "#{Rails.root}/config/lokalise_rails.rb"

# Import the files:
result = LokaliseRails::TaskDefinition::Importer.import!
```
`result` contains a boolean value with the result of the operation

```ruby
# Export the files:
processes = LokaliseRails::TaskDefinition::Exporter.export!
```

`processes` contains a list of [queued background processes](https://lokalise.github.io/ruby-lokalise-api/api/queued-processes).

## Configuration

Options are specified in the `config/lokalise_rails.rb` file.

### Global settings

* `api_token` (`string`, required) - Lokalise API token with read/write permissions.
* `project_id` (`string`, required) - Lokalise project ID. You must have import/export permissions in the specified project.
* `locales_path` (`string`) - path to the directory with your translation files. Defaults to `"#{Rails.root}/config/locales"`.
* `file_ext_regexp` (`regexp`) - regular expression applied to file extensions to determine which files should be imported and exported. Defaults to `/\.ya?ml\z/i` (YAML files).
* `branch` (`string`) - Lokalise project branch to use. Defaults to `"master"`.
* `timeouts` (`hash`) - set [request timeouts for the Lokalise API client](https://lokalise.github.io/ruby-lokalise-api/additional_info/customization#setting-timeouts). By default, requests have no timeouts: `{open_timeout: nil, timeout: nil}`. Both values are in seconds.

### Import settings

* `import_opts` (`hash`) - options that will be passed to Lokalise API when downloading translations to your app. Here are the default options:

```ruby
{
  format: 'yaml',
  placeholder_format: :icu,
  yaml_include_root: true,
  original_filenames: true,
  directory_prefix: '',
  indentation: '2sp'
}
```

Full list of available import options [can be found in the official API documentation](https://app.lokalise.com/api2docs/curl/#transition-download-files-post).
* `import_safe_mode` (`boolean`) - default to `false`. When this option is enabled, the import task will check whether the directory set with `locales_path` is empty or not. If it is not empty, you will be prompted to continue.

### Export settings

* `export_opts` (`hash`) - options that will be passed to Lokalise API when uploading translations. Full list of available export options [can be found in the official documentation](https://app.lokalise.com/api2docs/curl/#transition-download-files-post). By default, the following options are provided:
  + `data` (`string`, required) - base64-encoded contents of the translation file.
  + `filename` (`string`, required) - translation file name. If the file is stored under a subdirectory (for example, `nested/en.yml` inside the `locales/` directory), the whole path acts as a name. Later when importing files with such names, they will be placed into the proper subdirectories.
  + `lang_iso` (`string`, required) - language ISO code which is determined using the root key inside your YAML file. For example, in this case the `lang_iso` is `en_US`:

```yaml
en_US:
  my_key: "my value"
```

**Please note** that if your Lokalise project does not have a language with the specified `lang_iso` code, the export will fail.

* `skip_file_export` (`lambda` or `proc`) - specify additional exclusion criteria for the exported files. By default, the rake task will ignore all non-file entries and all files with improper extensions (the latter is controlled by the `file_ext_regexp`). Lambda passed to this option should accept a single argument which is full path to the file (instance of the [`Pathname` class](https://ruby-doc.org/stdlib-2.7.1/libdoc/pathname/rdoc/Pathname.html)). For example, to exclude all files that have `fr` part in their names, add the following config:

```ruby
c.skip_file_export = ->(file) { f.split[1].to_s.include?('fr') }
```

## Running tests

1. Copypaste `.env.example` file as `.env`. Put your Lokalise API token and project ID inside. The `.env` file is excluded from version control so your data is safe. All in all, we use pre-recorded VCR cassettes, so the actual API requests won’t be sent. However, providing at least some values is required.
2. Run `rspec .`. Observe test results and code coverage.

## License

Copyright (c) [Lokalise team](http://lokalise.com), [Ilya Bodrov](http://bodrovis.tech). License type is [MIT](https://github.com/bodrovis/lokalise_rails/blob/master/LICENSE).
