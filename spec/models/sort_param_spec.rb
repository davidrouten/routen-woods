require "rails_helper"

RSpec.describe SortParam do
  describe "ascending sort" do
    subject { SortParam.new("name") }

    it { expect(subject.column).to eq("name") }
    it { expect(subject.direction).to eq("asc") }
    it { expect(subject.desc?).to be false }
    it { expect(subject.active?).to be true }
  end

  describe "descending sort" do
    subject { SortParam.new("-name") }

    it { expect(subject.column).to eq("name") }
    it { expect(subject.direction).to eq("desc") }
    it { expect(subject.desc?).to be true }
    it { expect(subject.active?).to be true }
  end

  describe "nil param" do
    subject { SortParam.new(nil) }

    it { expect(subject.column).to be_nil }
    it { expect(subject.direction).to eq("asc") }
    it { expect(subject.desc?).to be false }
    it { expect(subject.active?).to be false }
  end

  describe "empty string" do
    subject { SortParam.new("") }

    it { expect(subject.column).to be_nil }
    it { expect(subject.active?).to be false }
  end
end
