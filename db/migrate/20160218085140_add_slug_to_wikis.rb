class AddSlugToWikis < ActiveRecord::Migration
  def change
    add_column :wikis, :slug, :string
  end
end
