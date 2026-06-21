FactoryBot.define do
  factory :order_form do
    association :project
    supplier_name { "Cabinet Supply Co" }
    status { :draft }

    trait :with_items do
      after(:create) do |order_form|
        create(:order_line_item, order_form: order_form, name: "Shaker Door Front", quantity: 14, supplier_cost: 45.00, our_price: 65.00)
        create(:order_line_item, order_form: order_form, name: "Drawer Front", quantity: 8, supplier_cost: 30.00, our_price: 45.00)
      end
    end
  end

  factory :order_line_item do
    association :order_form
    name { "Shaker Door Front" }
    category { "door_front" }
    color { "White" }
    finish { "Matte" }
    material { "3DL" }
    quantity { 1 }
    supplier_cost { 45.00 }
    our_price { 65.00 }
    markup_pct { 44.44 }
  end
end
