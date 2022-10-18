require 'test/unit'
require_relative '../../lib/kudu/erubis_inflater.rb'

class TestErubisInflater < Test::Unit::TestCase

  def setup
    @template = __FILE__.gsub(File.basename(__FILE__), 'template.erb')
  end

  def test_read_template_file
    assert_nothing_raised do
      ErubisInflater::read_template_file(@template)
    end
  end

  def test_inflate_file
    assert_nothing_raised do
      text = ErubisInflater::inflate_file(@template, {:string=>'blah'})
      puts text
#      assert_equal(text,'hello', "ERB template expansion failed")
    end
  end

  def test_inflate_file_write
    assert_nothing_raised do
      output_file = File.dirname(__FILE__) + '/hello.txt'
      ErubisInflater::inflate_file_write(@template, {:string=>'hello'}, output_file)
      text = IO.read(output_file)
      assert_equal(text,'hello', "ERB template expansion failed")
    end
  end


end



