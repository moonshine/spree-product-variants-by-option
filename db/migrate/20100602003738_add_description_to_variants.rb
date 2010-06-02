class AddDescriptionToVariants < ActiveRecord::Migration
  def self.up
    add_column :variants, :short_description, :string
  end

  def self.down
    remove_column :variants, :short_description
  end
end