# frozen_string_literal: true

require_relative 'lib/solidus_klarna_payments/version'

Gem::Specification.new do |spec|
  spec.name = 'solidus_klarna_payments'
  spec.version = SolidusKlarnaPayments::VERSION
  spec.authors = ['Jose Antonio Pio Gil', 'Pascal Jungblut']
  spec.email = '["jose.pio@bitspire.de", "pascal.jungblut@bitspire.de"]'

  spec.summary = 'Klarna Payments integration for Solidus.'
  spec.homepage = 'https://github.com/solidusio-contrib/solidus_klarna_payments'
  spec.license = 'Apache-2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/solidusio-contrib/solidus_klarna_payments'
  spec.metadata['changelog_uri'] = 'https://github.com/solidusio-contrib/solidus_klarna_payments/blob/master/CHANGELOG.md'

  spec.required_ruby_version = Gem::Requirement.new('~> 2.5')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }

  spec.files = files.grep_v(%r{^(test|spec|features)/})
  spec.test_files = files.grep(%r{^(test|spec|features)/})
  spec.bindir = "exe"
  spec.executables = files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activemerchant'
  spec.add_dependency 'deface'
  spec.add_dependency 'klarna_client'
  spec.add_dependency 'solidus_core', ['>= 2.0.0', '< 4']
  spec.add_dependency 'solidus_support', '~> 0.8'

  spec.add_development_dependency 'site_prism'
  spec.add_development_dependency 'solidus_dev_support'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
end
