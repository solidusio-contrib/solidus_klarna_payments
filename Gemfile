source 'https://rubygems.org'

spree_version = ENV["SPREE_VERSION"] || "~> 2.3.0"
spree_auth_devise_version = ENV["SPREE_AUTH_DEVISE_VERSION"] || "2-3-stable"

gem "spree", spree_version

gemspec

if spree_auth_devise_version != "none"
  gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: spree_auth_devise_version
else
  gem 'spree_auth_devise'
end
