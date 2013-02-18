module Kudu
  def self.with_friendly_errors
    begin
      yield
    rescue Kudu::KuduError => e
      Kudu.ui.error e.message
      Kudu.ui.debug e.backtrace.join("\n")
      exit e.status_code
    rescue Interrupt => e
      Kudu.ui.error "\nQuitting..."
      Kudu.ui.debug e.backtrace.join("\n")
      exit 1
    rescue SystemExit => e
      exit e.status
    rescue Exception => e
      Kudu.ui.error(
        "Unfortunately, a fatal error has occurred.")
      raise e
    end
  end
end

