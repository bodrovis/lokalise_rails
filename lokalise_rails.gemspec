# frozen_string_literal: true

require File.expand_path('lib/lokalise_rails/version', __dir__)

Gem::Specification.new do |spec|
  spec.name                  = 'lokalise_rails'
  spec.version               = LokaliseRails::VERSION
  spec.authors               = ['Ilya Krukowski']
  spec.email                 = ['golosizpru@gmail.com']
  spec.summary               = 'Lokalise integration for Ruby on Rails'
  spec.description           = 'This gem allows to exchange translation files between your Rails app and Lokalise TMS.'
  spec.homepage              = 'https://github.com/bodrovis/lokalise_rails'
  spec.license               = 'MIT'
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 3.0'

  spec.files = Dir['README.md', 'LICENSE.md',
                   'CHANGELOG.md', 'lib/**/*.rb',
                   'lib/**/*.rake',
                   'lokalise_rails.gemspec']
  spec.extra_rdoc_files = ['README.md']
  spec.require_paths    = ['lib']

  spec.add_dependency 'lokalise_manager', '~> 7.0'
  spec.add_dependency 'zeitwerk', '~> 2.4'

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.5'
  spec.add_development_dependency 'rubocop-rake', '~> 0.7'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.22'

  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'bug_tracker_uri' => 'https://github.com/bodrovis/lokalise_rails/issues',
    'changelog_uri' => 'https://github.com/bodrovis/lokalise_rails/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/bodrovis/lokalise_rails/blob/master/README.md',
    'homepage_uri' => spec.homepage
  }
end
