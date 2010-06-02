class AddDisplayVariantsByOptionToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :display_variants_by_option, :string
  end

  def self.down
    remove_column :products, :display_variants_by_option
  end
end