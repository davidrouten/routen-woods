class AddTurnstilePassedToLeads < ActiveRecord::Migration[8.1]
  def change
    add_column :leads, :turnstile_passed, :boolean
  end
end
