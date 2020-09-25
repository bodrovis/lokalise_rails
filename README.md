# LokaliseRails

<!-- [![Gem Version](https://badge.fury.io/rb/ruby-lokalise-api.svg)](https://badge.fury.io/rb/ruby-lokalise-api) -->
[![Build Status](https://travis-ci.org/bodrovis/lokalise_rails.svg?branch=master)](https://travis-ci.org/bodrovis/lokalise_rails)
[![Test Coverage](https://codecov.io/gh/bodrovis/lokalise_rails/graph/badge.svg)](https://codecov.io/gh/bodrovis/lokalise_rails)

This gem provides [Lokalise](http://lokalise.com) integration for Ruby on Rails and allows to exchange translation files easily. It relies on [ruby-lokalise-api](https://lokalise.github.io/ruby-lokalise-api) to send APIv2 requests.

## Getting started

### Requirements

This gem requires Ruby 2.5+ and Rails 5.1+. It might work with older versions of Rails though. You will also need to setup a Lokalise account and a translation project. Finally, you will need to generate a read/write API token at your Lokalise profile.

### Installation

Add the gem to your `Gemfile`

```ruby
gem 'lokalise_rails'
```

and run

```
bundle install
rails g lokalise_rails:install
```

The latter command will generate a new initializer `lokalise_rails.rb` looking like this:

```ruby
require 'lokalise_rails'

LokaliseRails.api_token = ENV['LOKALISE_API_TOKEN']
LokaliseRails.project_id = ENV['LOKALISE_PROJECT_ID']
# ...
```

You have to provide `api_token` and `project_id` to proceed. Other options can be customized as well (see below) but they have sensible defaults.

## Importing translations from Lokalise

To import translations from the specified Lokalise project to your Rails app, run the following command:

```
rails lokalise_rails:import
```

Please note that any existing files inside the `locales` directory will be overwritten! You may enable safe mode to check if the folder is empty or not.

## Configuration

Options are specified in the `config/initializers/lokalise_rails.rb` file.

### Global settings

* `LokaliseRails.api_token` (`string`, required) - Lokalise API token with read/write permissions.
* `LokaliseRails.project_id` (`string`, required) - Lokalise project ID. You must have import/export permissions in the specified project.
* `locales_path` - method returning a string with the path to your translation files. Defaults to `"#{Rails.root}/config/locales"`. To provide a custom path, override the method inside the initializer (make sure that the path exists!):

```ruby
class LokaliseRails
  class << self
    def locales_path
      "#{Rails.root}/config/locales_custom"
    end
  end
end
```

### Import settings

* `LokaliseRails.import_opts` (`hash`) - options that will be passed to Lokalise API when downloading translations to your app. Here are the default options:

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

Full list of available options [can be found at the official API documentation](https://app.lokalise.com/api2docs/curl/#transition-download-files-post).
* `LokaliseRails.import_safe_mode` (`boolean`) - default to `false`. When this option is enabled, the import task will check whether the `locales` directory is empty or not. If it is not empty, you will be prompted to continue.

## License

Copyright (c) [Lokalise team](http://lokalise.com), [Ilya Bodrov](http://bodrovis.tech)
