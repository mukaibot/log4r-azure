$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "log4r-azure"
  s.version     = "0.8.25"
  s.license     = "GPLv2"
  s.authors     = ["Timothy Mukaibo"]
  s.email       = ["timothy@mukaibo.com"]
  s.homepage    = "https://github.com/mukaibot/azure-logging-rails"
  s.summary     = "Windows Azure Table Storage Outputter for log4r"
  s.description = "log4r-azure allows you to use Windows Azure Table Storage as a log outputter in Log4r. No more HA syslog!"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "log4r", "~> 1.1.10"
  s.add_dependency "azure"
end
