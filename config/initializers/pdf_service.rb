Rails.application.config.to_prepare do
  PdfService.renderer_class = "PdfService::FerumRenderer"
end

chrome_path = ENV["GOOGLE_CHROME_BIN"] || ENV["BROWSER_PATH"]
if chrome_path.present?
  FerrumPdf.configure do |config|
    config.browser_path = chrome_path
    config[:"no-sandbox"] = nil
  end
end
