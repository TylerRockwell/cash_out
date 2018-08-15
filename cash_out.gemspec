Gem::Specification.new do |s|
  s.name = 'cash_out'
  s.version = '0.0.1'
  s.date = '2018-08-13'
  s.summary = 'A gem to ease setup of Stripe Marketplace Payments'
  s.description = 'A gem to ease setup of Stripe Marketplace Payments'
  s.authors = ['Tyler Rockwell']
  s.files = %w(README.md) + Dir.glob(File.join('lib', '**', '*.rb'))
  s.homepage = 'http://rubygems.org/gems/cash_out'
  s.license = 'MIT'

  s.add_dependency 'active_interaction', '~> 3.6'
  s.add_dependency 'stripe', '~> 3.21'
end
