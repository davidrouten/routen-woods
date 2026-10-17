require "rails_helper"

RSpec.describe Admin::SortHelper, type: :helper do
  def link_for(path, params = {}, label: "Name", column: :name, **options)
    helper.request.path = path
    helper.request.env["QUERY_STRING"] = params.to_query
    sort = SortParam.new(params["sort"])
    helper.define_singleton_method(:current_sort) { sort }
    Nokogiri::HTML.fragment(helper.sort_link(label, column, **options)).at("a")
  end

  it "links to the current path with the sort param" do
    link = link_for("/admin/customers")

    expect(link["href"]).to eq("/admin/customers?sort=name")
  end

  it "keeps other query params" do
    link = link_for("/admin/customers", { "q" => "smith" })

    expect(link["href"]).to eq("/admin/customers?q=smith&sort=name")
  end

  it "toggles to descending when already sorted ascending" do
    link = link_for("/admin/customers", { "sort" => "name" })

    expect(link["href"]).to eq("/admin/customers?sort=-name")
  end

  it "drops the sort param when returning to the page default" do
    link = link_for("/admin/projects", { "sort" => "-schedule" }, column: :schedule, page_default: true)

    expect(link["href"]).to eq("/admin/projects")
  end

  it "ignores host and protocol params so the link stays on this site" do
    link = link_for("/admin/customers", { "host" => "evil.example", "protocol" => "javascript" })

    expect(link["href"]).to start_with("/admin/customers?")
  end

  it "escapes the label" do
    link = link_for("/admin/customers", label: "<script>x</script>")

    expect(link.inner_html).to include("&lt;script&gt;")
    expect(link.at("script")).to be_nil
  end
end
