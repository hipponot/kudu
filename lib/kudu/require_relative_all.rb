
# shorthand to require_relative for all files in Directory glob
def require_relative_all(pattern)
  Dir.glob("#{File.join(File.dirname(__FILE__), '', pattern)}").each do |d|
    require_relative d.gsub(File.join(File.dirname(__FILE__), ''), '')
  end
end
