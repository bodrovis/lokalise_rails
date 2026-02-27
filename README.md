# LokaliseRails

![Gem](https://img.shields.io/gem/v/lokalise_rails)
![CI](https://github.com/bodrovis/lokalise_rails/actions/workflows/ci.yml/badge.svg)
[![Code Coverage](https://qlty.sh/gh/bodrovis/projects/lokalise_rails/coverage.svg)](https://qlty.sh/gh/bodrovis/projects/lokalise_rails)
[![Maintainability](https://qlty.sh/gh/bodrovis/projects/lokalise_rails/maintainability.svg)](https://qlty.sh/gh/bodrovis/projects/lokalise_rails)
![Downloads total](https://img.shields.io/gem/dt/lokalise_rails)

This gem provides [Lokalise](http://lokalise.com) integration for Ruby on Rails and allows you to exchange translation files easily. It relies on [lokalise_manager](https://github.com/bodrovis/lokalise_manager) which performs the actual import/export and can be used to run these tasks in any Ruby script.

*If you would like to know how this gem was built, check out the ["How to create a Ruby gem" series at Lokalise blog](https://lokalise.com/blog/create-a-ruby-gem-basics/).*

## Getting started

### Requirements

This gem requires Ruby 3.0+ and Rails 5.1+. It might work with older versions of Rails though. You will also need to [set up a Lokalise account](https://app.lokalise.com/signup) and create a [translation project](https://docs.lokalise.com/en/articles/1400460-projects). Finally, you will need to generate a [read/write API token](https://docs.lokalise.com/en/articles/1929556-api-tokens) at your Lokalise profile (or a read-only token if you plan to perform only imports).

Alternatively, you can utilize a token obtained via OAuth 2 flow. When using such a token, you'll have to set `:use_oauth2_token` option to `true` (please check [options docs](https://github.com/bodrovis/lokalise_manager#common-config) to learn more).

### Installation

Add the gem to your `Gemfile` (it can be added to the `development` group if you're not planning to import/export translations in production):

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
LokaliseRails::GlobalConfig.config do |c|
  c.api_token = ENV['LOKALISE_API_TOKEN']
  c.project_id = ENV['LOKALISE_PROJECT_ID']

  # ...other options
end
```

- `api_token` is required.  
- `project_id` is required for the default project (either in the main config block as shown above or in `for_default_project`), and for each named project configured via `for_project`. `project_id` can be found in your Lokalise project settings.

> You can configure the default project either via the main config block (classic way) or via `for_default_project` (useful when you want per-project configs consistently, see below).

Other options can be customized as well but they have sensible defaults. To learn about all the available options please check [lokalise_manager docs](https://github.com/bodrovis/lokalise_manager#configuration). The generated config file also contains some examples to help you get started.

## Importing translations from Lokalise

To import translations from the specified Lokalise project to your Rails app, run the following command:

```
rails lokalise_rails:import
```

Please note that any duplicating files inside the `locales` directory (or any other directory that you've specified in the options) will be overwritten! You can enable [safe mode](https://github.com/bodrovis/lokalise_manager#import-config) to check whether the folder is empty or not.

## Exporting translations to Lokalise

To export translations from your Rails app to the specified Lokalise project, run the following command:

```
rails lokalise_rails:export
```

## Configuration

Options are specified in the `config/lokalise_rails.rb` file.

Here's an example:

```ruby
LokaliseRails::GlobalConfig.config do |c|
  # These are mandatory options that you must set before running rake tasks:
  c.api_token = ENV['LOKALISE_API_TOKEN']
  c.project_id = ENV['LOKALISE_PROJECT_ID']

  # Provide a custom path to the directory with your translation files:
  # c.locales_path = "#{Rails.root}/config/locales"

  # Provide a Lokalise project branch to use:
  c.branch = 'develop'

  # Provide request timeouts for the Lokalise API client:
  c.additional_client_opts = {open_timeout: 5, timeout: 5}

  # Provide maximum number of retries for file exporting:
  c.max_retries_export = 5

  # Provide maximum number of retries for file importing:
  c.max_retries_import = 5

  # Import options have the following defaults:
  # c.import_opts = {
  #   format: 'ruby_yaml',
  #   placeholder_format: :icu,
  #   yaml_include_root: true,
  #   original_filenames: true,
  #   directory_prefix: '',
  #   indentation: '2sp'
  # }

  # Safe mode for imports is disabled by default:
  # c.import_safe_mode = false

  # Additional export options (only filename, contents, and lang_iso params are provided by default)
  # c.export_opts = {}

  # Provide additional file exclusion criteria for exports (by default, any file with the proper extension will be exported)
  # c.skip_file_export = ->(file) { file.split[1].to_s.include?('fr') }

  # Set the options below if you would like to work with format other than YAML
  ## Regular expression to use when choosing the files to extract from the downloaded archive and upload to Lokalise
  ## c.file_ext_regexp = /\.ya?ml\z/i

  ## Load translations data and make sure they are valid:
  ## c.translations_loader = ->(raw_data) { YAML.safe_load raw_data }

  ## Convert translations data to a proper format:
  ## c.translations_converter = ->(raw_data) { YAML.dump(raw_data).gsub(/\\\\n/, '\n') }

  ## Infer language ISO code for the translation file:
  ## c.lang_iso_inferer = ->(data, _path) { YAML.safe_load(data)&.keys&.first }

  ## Pre-process translations before exporting to Lokalise:
  ## c.export_preprocessor = ->(raw_data, _path) { raw_data }

  ## Disable the export rake task:
  ## c.disable_export_task = false

  ## Disable the import rake task:
  ## c.disable_import_task = false
end
```

## Running tasks programmatically

You can also run the import and export tasks programmatically from your code. To achieve that, please check the [`lokalise_manager`](https://github.com/bodrovis/lokalise_manager) gem which `lokalise_rails` relies on.

For example, you can use the following approach:

```ruby
# This line is actually not required. Include it if you would like to use your global settings:
require Rails.root.join("config", "lokalise_rails")

importer = LokaliseManager.importer({api_token: '1234abc', project_id: '123.abc'}, LokaliseRails::GlobalConfig)

# OR

exporter = LokaliseManager.exporter({api_token: '1234abc', project_id: '123.abc'}, LokaliseRails::GlobalConfig)
```

- The first argument passed to `importer` or `exporter` is the hash containing per-client options. This is an optional argument and you can simply pass an empty hash if you don't want to override any global settings.
- The second argument is the name of your global config which is usually stored inside the `lokalise_rails.rb` file (however, you can subclass this global config and even adjust the defaults [as explained here](https://github.com/bodrovis/lokalise_manager#overriding-defaults)).
  + If you would like to use `LokaliseRails` global defaults, then you must pass this class to the clients. If you don't do this, then `LokaliseManager` defaults will be used instead. The only difference is the location where translation files are stored. For `LokaliseManager` we use `./locales` directory, whereas for `LokaliseRails` the directory is `./config/locales`.

However, you can also provide the translation files folder on per-client basis, for instance:

```ruby
importer = LokaliseManager.importer api_token: '1234abc', project_id: '123.abc', locales_path: Rails.root.join("config", "lokalise_rails")
```

After the client is instantiated, you can run the corresponding task:

```ruby
importer.import!

# OR 

exporter.export!
```

### Example: Multiple translation paths

Creating custom import/export script can come in really handy if you have a non-standard setup, for instance, your translation files are stored in multiple directories (not only in the default `./config/locales`). To overcome this problem, create a custom Rake task and provide as many importers/exporters as needed:

```ruby
require 'rake'
require 'lokalise_rails'
require Rails.root.join("config", "lokalise_rails")

namespace :lokalise_custom do
  task :export do
    # exporting from the default directory (./config/locales/)
    exporter = LokaliseManager.exporter({}, LokaliseRails::GlobalConfig)
    exporter.export!

    # exporting from the custom directory
    exporter = LokaliseManager.exporter({locales_path: "#{Rails.root}/config/custom_locales"}, LokaliseRails::GlobalConfig)
    exporter.export!
  rescue StandardError => e
    abort e.inspect
  end
end
```

## Multiple Lokalise projects

If your Rails app needs to sync with more than one Lokalise project (different `project_id`, possibly a different `api_token`), use `for_project` in `config/lokalise_rails.rb`. It registers a named, isolated config and automatically generates scoped rake tasks without changing the existing `lokalise_rails:import` and `lokalise_rails:export` tasks.

```ruby
# config/lokalise_rails.rb

# Main project — unchanged
LokaliseRails::GlobalConfig.config do |c|
  c.api_token  = ENV['LOKALISE_API_TOKEN']
  c.project_id = ENV['LOKALISE_PROJECT_ID']
end

# Additional project
LokaliseRails::GlobalConfig.for_project(:mobile) do |c|
  c.project_id  = ENV['LOKALISE_MOBILE_PROJECT_ID']
  c.locales_path = "#{Rails.root}/config/locales/mobile"
end
```

This generates the following rake tasks automatically:

```
rails lokalise_rails:import         # existing - uses the main config
rails lokalise_rails:export         # existing - uses the main config
rails lokalise_rails:mobile:import  # auto-generated — uses the :mobile config
rails lokalise_rails:mobile:export  # auto-generated — uses the :mobile config
```

Any setting not explicitly set in the `for_project` block falls back to the main `GlobalConfig`, so shared options like `api_token` only need to be written once:

```ruby
LokaliseRails::GlobalConfig.config do |c|
  c.api_token  = ENV['LOKALISE_API_TOKEN']  # shared by all projects
  c.project_id = ENV['LOKALISE_PROJECT_ID']
end

LokaliseRails::GlobalConfig.for_project(:mobile) do |c|
  # api_token is inherited from the main config above
  c.project_id  = ENV['LOKALISE_MOBILE_PROJECT_ID']
  c.locales_path = "#{Rails.root}/config/locales/mobile"
end
```

You can register as many named projects as needed and sync them all in one command:

```
rails lokalise_rails:import lokalise_rails:mobile:import
```

> **Note:** `for_project` is designed for apps that need multiple distinct Lokalise projects. If you only need to sync multiple local directories against the same project, the `lokalise_custom` rake task pattern described above is sufficient.

### Default project vs named projects

The default rake tasks:

- `rails lokalise_rails:import`
- `rails lokalise_rails:export`

use the default project options.

You can configure the default project in two ways:

*Classic (backward-compatible) way* — set `project_id` (and optionally `locales_path`, etc.) in the main config block:

```ruby
LokaliseRails::GlobalConfig.config do |c|
  c.api_token  = ENV['LOKALISE_API_TOKEN']
  c.project_id = ENV['LOKALISE_PROJECT_ID']
end
```

*Unified per-project way* — set default project overrides via `for_default_project`:

```ruby
LokaliseRails::GlobalConfig.config do |c|
  c.api_token = ENV['LOKALISE_API_TOKEN']
end

LokaliseRails::GlobalConfig.for_default_project do |c|
  c.project_id   = ENV['LOKALISE_PROJECT_ID']
  c.locales_path = "#{Rails.root}/config/locales"
end
```

Named projects are configured with `for_project(:name)` and generate scoped tasks like `lokalise_rails:<name>:import` and `lokalise_rails:<name>:export`.

## Running tests

1. Copy-paste `.env.example` file as `.env`. Put your Lokalise API token and project ID inside. The `.env` file is excluded from version control so your data is safe. All in all, we use stubbed requests, so the actual API requests won't be sent. However, providing at least some values is required.
2. Run `rspec .`. Observe test results and code coverage.

## License

Copyright (c) [Ilya Krukowski](http://bodrovis.tech). License type is [MIT](https://github.com/bodrovis/lokalise_rails/blob/master/LICENSE.md).
