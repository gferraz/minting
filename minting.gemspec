lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minting/version'

Gem::Specification.new do |s|
  s.name          = 'minting'
  s.summary       = 'Library to manipulate currency.'
  s.description   = s.summary
  s.homepage      = 'https://github.com/gferraz/minting'
  s.version       = Minting::VERSION
  s.authors       = ['Gilson Ferraz']
  s.email         = []
  s.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org.
  # To allow pushes either set the 'allowed_push_host' to allow pushing to
  # a single host or delete this section to allow pushing to any host.
  raise 'RubyGems 2.0 or newer is required' unless s.respond_to?(:metadata)

  s.metadata = {
    'bug_tracker_uri'   => s.homepage + '/issues',
    'changelog_uri'     => s.homepage + '/blob/master/CHANGELOG.md',
    'homepage_uri'      => s.homepage,
    'source_code_uri'   => s.homepage,
    'allowed_push_host' => "TODO: Set to 'https://mygemserver.com'"
  }

  s.required_ruby_version = '>= 2.2.0'

  s.files = Dir.glob('{bin,doc,lib}/**/*')
  s.files += %w[minting.gemspec Rakefile README.md]

  s.bindir        = 'bin'
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubycritic'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'yard'
end
