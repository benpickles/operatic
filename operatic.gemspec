lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'operatic/version'

Gem::Specification.new do |spec|
  spec.name          = 'operatic'
  spec.version       = Operatic::VERSION
  spec.authors       = ['Ben Pickles']
  spec.email         = ['spideryoung@gmail.com']

  spec.summary       = 'A minimal standard interface for your operations'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/benpickles/operatic'
  spec.license       = 'MIT'

  spec.metadata = {
    'changelog_uri'     => 'https://github.com/benpickles/operatic/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://rubydoc.info/gems/operatic',
    'source_code_uri'   => 'https://github.com/benpickles/operatic',
  }

  spec.required_ruby_version = '>= 2.7.0'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
