
Gem::Specification.new do |spec|
  spec.name          = "embulk-input-restforce"
  spec.version       = "0.1.7"
  spec.authors       = ["sonesuke"]
  spec.summary       = "Restforce input plugin for Embulk"
  spec.description   = "Loads records from Restforce."
  spec.email         = ["iamsonesuke@gmail.com"]
  spec.licenses      = ["MIT"]
  spec.homepage      = "https://github.com/sonesuke/embulk-input-restforce"

  spec.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  #spec.add_dependency 'YOUR_GEM_DEPENDENCY', ['~> YOUR_GEM_DEPENDENCY_VERSION']
  spec.add_dependency 'restforce', ['~> 2.5.2']
  spec.add_development_dependency 'embulk', ['>= 0.8.39']
  spec.add_development_dependency 'bundler', ['>= 1.10.6']
  spec.add_development_dependency 'rake', ['>= 10.0']
end
