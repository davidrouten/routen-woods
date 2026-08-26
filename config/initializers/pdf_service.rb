Rails.application.config.to_prepare do
  PdfService.renderer_class = "PdfService::FerumRenderer"
end
