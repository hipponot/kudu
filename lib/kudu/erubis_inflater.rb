require 'erubis'

class ErubisInflater

  def self.inflate_file_write(template, settings, outfile)
    # Read template
    text = self.read_template_file template
    result = inflate_text(text, settings)
    # Write result to file
    File.unlink(outfile) if (File.exists?(outfile)) 
    IO.write(outfile, result)
  end

  def self.inflate_file(template, settings)
    # Read template
    text = self.read_template_file template
    inflate_text(text, settings)
  end

  def self.inflate_text(text, settings)
    erbtmpl = Erubis::Eruby.new(text)
    result = erbtmpl.result(settings)
    result = result.gsub(/^\s+$/,'')
    result = result.gsub(/\n$/,'')
    return result
  end

  def self.read_template_file(template)
    IO.read(template)
  end

end
