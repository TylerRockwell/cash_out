lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cash_out/version"

Gem::Specification.new do |s|
  s.name = 'cash_out'
  s.version = CashOut::VERSION
  s.date = '2018-08-13'
  s.summary = 'A gem to ease setup of Stripe Marketplace Payments'
  s.description = 'A gem to ease setup of Stripe Marketplace Payments'
  s.authors = ['Tyler Rockwell']
  s.files = %w(README.md) + Dir.glob(File.join('lib', '**', '*.rb'))
  s.homepage = 'http://rubygems.org/gems/cash_out'
  s.license = 'MIT'

  s.add_dependency 'active_interaction', '~> 3.6'
  s.add_dependency 'stripe', '~> 3.21'
  s.add_dependency 'railties', '< 6.0'


  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.16"
  s.add_development_dependency "pry-byebug"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "rspec-activemodel-mocks"
  s.add_development_dependency 'stripe-ruby-mock', '~> 2.5.4'
end
