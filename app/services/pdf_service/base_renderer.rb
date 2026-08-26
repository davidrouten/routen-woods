module PdfService
  class BaseRenderer
    def render(html, options = {})
      raise NotImplementedError, "#{self.class}#render must return PDF binary data"
    end
  end
end
