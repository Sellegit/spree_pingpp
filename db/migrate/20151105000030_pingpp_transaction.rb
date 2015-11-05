# some section piece is clickable, like taxon name, product name, post name,
# in some case, we don't want it to be clickable, ex. in product detail page, product name should not be clickable.
class AddThemeMediaWidth < ActiveRecord::Migration
  def change
    # a template has some compatible media width.
    create_table :spree_pingpp_transactions do |t|
      t.string :channel,:limit=>64
      t.string :charge_id, :limit=>128
    end
  end

end
