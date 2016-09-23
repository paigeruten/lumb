Gem::Specification.new do |s|
  s.name        = 'lumb'
  s.version     = '0.3.0'
  s.license     = 'MIT'
  s.summary     = 'strongly-typed personal logging'
  s.author      = 'Jeremy Ruten'
  s.email       = 'jeremy.ruten@gmail.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/yjerem/lumb'

  s.add_dependency 'parslet', '~> 1.7'
end

