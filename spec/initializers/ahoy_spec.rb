require "rails_helper"

RSpec.describe "Ahoy configuration" do
  describe "exclude_method" do
    it "is configured" do
      expect(Ahoy.exclude_method).to be_present
    end

    it "excludes /admin paths" do
      request = double(path: "/admin/leads")
      expect(Ahoy.exclude_method.call(nil, request)).to be true
    end

    it "excludes the /admin root" do
      request = double(path: "/admin")
      expect(Ahoy.exclude_method.call(nil, request)).to be true
    end

    it "does not exclude public paths" do
      request = double(path: "/")
      expect(Ahoy.exclude_method.call(nil, request)).to be false
    end

    it "does not exclude other paths" do
      request = double(path: "/contact")
      expect(Ahoy.exclude_method.call(nil, request)).to be false
    end
  end
end
