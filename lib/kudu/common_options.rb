
module CommonOptions
  method_option :verbose, :aliases => "-v", :type => :boolean, :required => false, :default=>false,  :desc => "Verbosity flag"
  method_option :profile, :aliases => "-p", :type =>:boolean, :required => false, :default => false,  :desc => "Profile"
end
