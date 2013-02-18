require 'test/unit'
require 'yaml'

class TestYAML < Test::Unit::TestCase
  
  def setup
  end
  
  def teardown
  end
  

  def test_yaml
    kudu = { 
      publication: {name:"foo_bar", namespace:"Cws", version:"0.0.1", group: "in-house"},
      dependencies:
      [
       {name:"json", version:"0.7.5", group: "third-party"},
       {name:"blah", version:"0.0.1", group: "in-house", namespace:"Cws"}  
      ]
    }
    File.open("kudu.yaml", "w") { |f| f.puts YAML::dump(kudu) }    
  end
end


