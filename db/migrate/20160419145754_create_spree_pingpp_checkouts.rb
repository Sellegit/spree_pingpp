class CreateSpreePingppCheckouts < ActiveRecord::Migration
  def change
    create_table :spree_pingpp_checkouts do |t|
      t.string :status
    end
    add_index :spree_pingpp_checkouts, :status
  end
end
