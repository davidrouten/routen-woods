module PdfService
  class FerumRenderer < BaseRenderer
    def render(html, options = {})
      pdf_options = {
        print_background: true,
        prefer_css_page_size: true
      }.merge(options)

      FerrumPdf.render_pdf(html: html, pdf_options: pdf_options)
    end
  end
end
