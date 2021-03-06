require_relative 'lib/club_lint/version'

Gem::Specification.new do |spec|
  spec.name    = 'club_lint'
  spec.version = ClubLint::VERSION
  spec.authors = ['Kai Hofius']
  spec.email   = ['kai@informedk12.com']

  spec.summary  = 'Toolkit to help manage a sprintly Clubhouse workflow'
  spec.homepage = 'https://github.com/kaifius/club-lint'
  spec.license  = 'MIT'

  spec.files       = `git ls-files lib util`.split($RS)
  spec.files      += ['README.md', 'LICENSE.txt']
  spec.bindir      = 'bin'
  spec.executables = `git ls-files bin`.split($RS).map { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'clubhouse_ruby', '0.4'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'pry', '~> 0.11'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rubocop', '~> 0.56'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.27.0'
end
