module Kudu
  class KuduError < StandardError; end
  class DuplicateProjectFound < KuduError; end
  class KuduSpecNotFound < KuduError;  end  
  class KuduSpecInHouseVersion < KuduError;  end  
  class ProjectpecNotFound < KuduError; end
  class InvalidGemfile < KuduError; end
  class InvalidKuduSpec < KuduError; end
  class InvalidOption < KuduError; end
  class BuildFailed < KuduError; end
  class CommandNotDefinedForType < KuduError; end
  class TemplateElaborationFailed < KuduError; end
  class BuildGemFailed < KuduError; end
end
