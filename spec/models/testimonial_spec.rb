require "rails_helper"

RSpec.describe Testimonial, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:author_name) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_inclusion_of(:rating).in_range(1..5) }
  end

  describe "scopes" do
    it ".featured returns only featured testimonials" do
      featured = create(:testimonial, featured: true)
      create(:testimonial, featured: false)
      expect(Testimonial.featured).to eq([featured])
    end
  end
end
