lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kudu_hello/version'
Gem::Specification.new do |gem|
  basedir = File.dirname(__FILE__)
  gem.name          = %q{kudu_hello}
  gem.authors       = ["Sean Kelly"]
  gem.email         = ["sean.kelly@wootlearning"]
  gem.description   = %q{Buildware with transitive dependency management in ruby}
  gem.summary       = %q{Buildware in ruby}
  gem.homepage      = %q{http://wootlearning.com}  
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
