$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "grape_has_scope"
  s.platform    = Gem::Platform::RUBY
  s.version     = "0.2.0"
  s.author      = "Kourza Ivan a.k.a. Phobos98"
  s.email       = "phobos98@phobos98.net"
  s.homepage    = "https://github.com/Phobos98/grape_has_scope.git"
  s.summary     = "has_scope implementation to use with Grape API"
  s.description = %{has_scope implementation to use with Grape API}
  s.license     = 'MIT'

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "grape_has_scope"

  s.files = Dir['lib/*.rb']
  s.require_path = 'lib'
  s.autorequire = 'builder'
  s.has_rdoc = true
  s.extra_rdoc_files = Dir['[A-Z]*']

end