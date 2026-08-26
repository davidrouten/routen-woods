module PdfService
  mattr_accessor :renderer_class, default: "PdfService::FerumRenderer"

  def self.render(html, options = {})
    renderer.render(html, options)
  end

  def self.renderer
    @renderer ||= renderer_class.constantize.new
  end

  def self.reset_renderer!
    @renderer = nil
  end
end
