require "rails_helper"

RSpec.describe PdfService do
  after do
    PdfService.renderer_class = "PdfService::FerumRenderer"
    PdfService.reset_renderer!
  end

  describe ".renderer_class" do
    it "defaults to FerumRenderer" do
      expect(PdfService.renderer_class).to eq("PdfService::FerumRenderer")
    end
  end

  describe ".renderer" do
    it "returns an instance of the configured renderer" do
      expect(PdfService.renderer).to be_a(PdfService::FerumRenderer)
    end

    it "can be swapped via renderer_class" do
      stub_const("PdfService::FakeRenderer", Class.new(PdfService::BaseRenderer) {
        def render(html, options = {})
          "%PDF-fake"
        end
      })
      PdfService.renderer_class = "PdfService::FakeRenderer"
      PdfService.reset_renderer!
      expect(PdfService.renderer).to be_a(PdfService::FakeRenderer)
    end
  end

  describe ".render" do
    it "produces PDF binary data from HTML" do
      pdf = PdfService.render("<h1>Test</h1>")
      expect(pdf).to start_with("%PDF")
      expect(pdf.encoding).to eq(Encoding::ASCII_8BIT)
    end
  end

  describe PdfService::BaseRenderer do
    it "raises NotImplementedError" do
      expect { PdfService::BaseRenderer.new.render("<h1>Test</h1>") }.to raise_error(NotImplementedError)
    end
  end

  describe PdfService::FerumRenderer do
    it "renders HTML to PDF via Ferrum" do
      pdf = PdfService::FerumRenderer.new.render("<h1>Hello World</h1>")
      expect(pdf).to start_with("%PDF")
    end
  end
end
