class DropRodauthTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :account_password_reset_keys
    drop_table :account_login_change_keys
    drop_table :account_verification_keys
    drop_table :account_remember_keys
    drop_table :accounts
  end
end
