module Kudu
  class KuduError < StandardError; end
  class DuplicateProjectFound < KuduError; end
  class KuduSpecNotFound < KuduError;  end  
  class KuduSpecInHouseVersion < KuduError;  end  
  class ProjectNotFound < KuduError; end
  class InvalidGemspec < KuduError; end
  class InvalidKuduSpec < KuduError; end
  class InvalidOption < KuduError; end
  class BuildFailed < KuduError; end
  class CommandNotDefinedForType < KuduError; end
  class TemplateElaborationFailed < KuduError; end
  class GemBuilderFailed < KuduError; end
  class FlexBuilderMainNotFound < KuduError; end
  class FlexBuilderAppXMLNotFound < KuduError; end
end
