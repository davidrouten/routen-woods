Rails.application.config.to_prepare do
  PdfService.renderer_class = "PdfService::FerumRenderer"
end

chrome_path = ENV["GOOGLE_CHROME_BIN"] || ENV["BROWSER_PATH"]
if chrome_path.present?
  FerrumPdf.configure do |config|
    config.browser_path = chrome_path
    config.process_timeout = 30
    config[:"no-sandbox"] = nil
    config[:"disable-gpu"] = nil
    config[:"disable-dev-shm-usage"] = nil
  end
end
