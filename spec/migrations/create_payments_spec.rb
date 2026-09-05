require "rails_helper"
require_relative "../../db/migrate/20260905165124_create_payments"

RSpec.describe CreatePayments do
  self.use_transactional_tests = false

  let(:conn) { ActiveRecord::Base.connection }
  let(:migration) { described_class.new }

  def rollback!
    ActiveRecord::Migration.suppress_messages { migration.migrate(:down) }
    Invoice.reset_column_information
  end

  def migrate!
    ActiveRecord::Migration.suppress_messages { migration.migrate(:up) }
    Invoice.reset_column_information
  end

  def insert_old_invoice(attrs = {})
    defaults = {
      invoice_number: "INV-MIG-#{SecureRandom.hex(4)}",
      status: 0,
      total: 0,
      subtotal: 0,
      tax_total: 0,
      fees_total: 0,
      amount_paid: 0,
      issued_date: Date.current,
      due_date: Date.current + 30,
      created_at: 1.week.ago,
      updated_at: 1.week.ago
    }
    row = defaults.merge(attrs)
    cols = row.keys.join(", ")
    vals = row.values.map { |v| conn.quote(v) }.join(", ")
    conn.execute("INSERT INTO invoices (#{cols}) VALUES (#{vals})")
    conn.select_value("SELECT id FROM invoices WHERE invoice_number = #{conn.quote(row[:invoice_number])}")
  end

  def payments_for(invoice_id)
    conn.select_all("SELECT * FROM payments WHERE invoice_id = #{invoice_id} ORDER BY deposit DESC, paid_at ASC").to_a
  end

  around do |example|
    rollback!
    example.run
  ensure
    if conn.table_exists?(:payments)
      conn.execute("DELETE FROM payments")
    end
    conn.execute("DELETE FROM invoices WHERE invoice_number LIKE 'INV-MIG-%'")
    migrate! unless conn.table_exists?(:payments)
  end

  describe "up" do
    it "creates no payments for invoices with zero amount_paid" do
      id = insert_old_invoice(amount_paid: 0, total: 7000)

      migrate!

      expect(payments_for(id)).to be_empty
    end

    it "creates a deposit payment when only deposit_paid_at is set" do
      deposit_time = 3.days.ago
      id = insert_old_invoice(
        amount_paid: 2000,
        total: 7000,
        deposit_amount: 2000,
        deposit_paid_at: deposit_time,
        balance_paid_at: nil
      )

      migrate!

      payments = payments_for(id)
      expect(payments.length).to eq(1)

      p = payments.first
      expect(p["amount"].to_d).to eq(2000)
      expect(p["deposit"]).to eq(true)
      expect(p["paid_at"]).to be_within(1.second).of(deposit_time)
    end

    it "creates a balance payment when deposit_paid_at is not set" do
      balance_time = 2.days.ago
      id = insert_old_invoice(
        amount_paid: 5000,
        total: 7000,
        balance_paid_at: balance_time,
        deposit_paid_at: nil
      )

      migrate!

      payments = payments_for(id)
      expect(payments.length).to eq(1)

      p = payments.first
      expect(p["amount"].to_d).to eq(5000)
      expect(p["deposit"]).to eq(false)
      expect(p["paid_at"]).to be_within(1.second).of(balance_time)
    end

    it "falls back to created_at when no timestamps are set" do
      created = 5.days.ago
      id = insert_old_invoice(
        amount_paid: 3000,
        total: 7000,
        deposit_paid_at: nil,
        balance_paid_at: nil,
        created_at: created,
        updated_at: created
      )

      migrate!

      payments = payments_for(id)
      expect(payments.length).to eq(1)
      expect(payments.first["paid_at"]).to be_within(1.second).of(created)
    end

    it "splits into deposit and balance when both timestamps are set" do
      deposit_time = 5.days.ago
      balance_time = 2.days.ago
      id = insert_old_invoice(
        amount_paid: 7000,
        total: 7000,
        deposit_amount: 2000,
        deposit_paid_at: deposit_time,
        balance_paid_at: balance_time
      )

      migrate!

      payments = payments_for(id)
      expect(payments.length).to eq(2)

      deposit = payments.find { |p| p["deposit"] == true }
      balance = payments.find { |p| p["deposit"] == false }

      expect(deposit["amount"].to_d).to eq(2000)
      expect(deposit["paid_at"]).to be_within(1.second).of(deposit_time)

      expect(balance["amount"].to_d).to eq(5000)
      expect(balance["paid_at"]).to be_within(1.second).of(balance_time)
    end

    it "preserves total amount_paid when splitting deposit and balance" do
      id = insert_old_invoice(
        amount_paid: 7000,
        total: 7000,
        deposit_amount: 2000,
        deposit_paid_at: 5.days.ago,
        balance_paid_at: 2.days.ago
      )

      migrate!

      total_migrated = conn.select_value("SELECT SUM(amount) FROM payments WHERE invoice_id = #{id}").to_d
      expect(total_migrated).to eq(7000)
    end

    it "handles deposit_amount equal to amount_paid with both timestamps" do
      deposit_time = 3.days.ago
      balance_time = 1.day.ago
      id = insert_old_invoice(
        amount_paid: 2000,
        total: 7000,
        deposit_amount: 2000,
        deposit_paid_at: deposit_time,
        balance_paid_at: balance_time
      )

      migrate!

      payments = payments_for(id)
      expect(payments.length).to eq(1)

      p = payments.first
      expect(p["amount"].to_d).to eq(2000)
      expect(p["deposit"]).to eq(true)
    end

    it "handles both timestamps with no deposit_amount by creating one deposit payment" do
      deposit_time = 4.days.ago
      id = insert_old_invoice(
        amount_paid: 3000,
        total: 7000,
        deposit_amount: nil,
        deposit_paid_at: deposit_time,
        balance_paid_at: 1.day.ago
      )

      migrate!

      payments = payments_for(id)
      expect(payments.length).to eq(1)

      p = payments.first
      expect(p["amount"].to_d).to eq(3000)
      expect(p["deposit"]).to eq(true)
    end

    it "removes old columns from invoices" do
      migrate!

      columns = conn.columns(:invoices).map(&:name)
      expect(columns).not_to include("amount_paid")
      expect(columns).not_to include("deposit_paid_at")
      expect(columns).not_to include("balance_paid_at")
    end

    it "migrates multiple invoices independently" do
      id1 = insert_old_invoice(
        amount_paid: 2000, total: 7000,
        deposit_amount: 2000,
        deposit_paid_at: 5.days.ago, balance_paid_at: nil
      )
      id2 = insert_old_invoice(
        amount_paid: 7000, total: 7000,
        deposit_amount: 2000,
        deposit_paid_at: 5.days.ago, balance_paid_at: 2.days.ago
      )
      id3 = insert_old_invoice(
        amount_paid: 0, total: 7000
      )

      migrate!

      expect(payments_for(id1).length).to eq(1)
      expect(payments_for(id2).length).to eq(2)
      expect(payments_for(id3).length).to eq(0)

      total1 = conn.select_value("SELECT SUM(amount) FROM payments WHERE invoice_id = #{id1}").to_d
      total2 = conn.select_value("SELECT SUM(amount) FROM payments WHERE invoice_id = #{id2}").to_d

      expect(total1).to eq(2000)
      expect(total2).to eq(7000)
    end
  end

  describe "down" do
    it "restores old columns with correct values" do
      deposit_time = 5.days.ago
      balance_time = 2.days.ago
      id = insert_old_invoice(
        amount_paid: 7000, total: 7000,
        deposit_amount: 2000,
        deposit_paid_at: deposit_time,
        balance_paid_at: balance_time
      )

      migrate!
      rollback!

      row = conn.select_one("SELECT amount_paid, deposit_paid_at, balance_paid_at FROM invoices WHERE id = #{id}")
      expect(row["amount_paid"].to_d).to eq(7000)
      expect(row["deposit_paid_at"]).to be_within(1.second).of(deposit_time)
      expect(row["balance_paid_at"]).to be_within(1.second).of(balance_time)
    end
  end
end
