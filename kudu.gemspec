lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kudu/version'
Gem::Specification.new do |gem|
  basedir = File.dirname(__FILE__)
  gem.name          = %q{kudu}
  gem.authors       = ["Sean Kelly", "Jeff Stroomer", "Phil James-Roxby", "Raul Rangel", "James Bailey", "Justin Bradley"]
  gem.email         = ["cws@disney.com"]
  gem.description   = %q{generic kudu module description}
  gem.summary       = %q{generic kudu module summary}
  gem.homepage      = %q{http://disney.com/create}  
  gem.files         = `git ls-files #{basedir}`.split($/) +
                      `git ls-files #{basedir} --others --exclude-standard`.split($/) + `find . -name sha1`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  begin
    text = IO.read(File.join(basedir,'kudu.yaml'))
    kudu = YAML::load(text)
    kudu[:dependencies].each do |dep|
      name = dep[:namespace].nil? ? dep[:name] : dep[:namespace] + "_" + dep[:name]
      gem.add_dependency name, dep[:version]
    end                                                   
    gem.version = kudu[:publication][:version]
  rescue
    abort("Error parsing kudu.yaml")
  end
end
