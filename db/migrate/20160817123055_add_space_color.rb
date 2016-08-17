class AddSpaceColor < ActiveRecord::Migration
  def change
    add_column :spaces, :color, :string
    add_column :spaces, :icon_url, :string
  end
end
