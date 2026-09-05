FactoryBot.define do
  factory :invoice do
    association :project
    issued_date { Date.current }
    due_date { Date.current + 30.days }
    deposit_amount { 2000.00 }
    status { :draft }

    trait :with_items do
      after(:create) do |invoice|
        create(:invoice_line_item, invoice: invoice, name: "Materials & Supplies", unit_price: 3500.00)
        create(:invoice_line_item, invoice: invoice, name: "Labor", unit_price: 3500.00)
        invoice.calculate_totals!
      end
    end
  end

  factory :invoice_line_item do
    association :invoice
    name { "Materials & Supplies" }
    quantity { 1 }
    unit_price { 3500.00 }
  end

  factory :invoice_adjustment do
    association :invoice
    label { "Sales Tax (6%)" }
    adjustment_type { "tax" }
    rate { 0.06 }
    amount { 420.00 }
  end

  factory :payment do
    association :invoice
    amount { 2000.00 }
    paid_at { Time.current }
    deposit { false }

    trait :deposit do
      deposit { true }
    end
  end
end
