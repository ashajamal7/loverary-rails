class RemoveUserRefFromAccounts < ActiveRecord::Migration[8.0]
  def change
    remove_reference :accounts, :user, foreign_key: true
  end
end
