class AddReportsCountAndPublishedAndImageToArticles < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :reports_count, :integer
    add_column :articles, :published, :boolean
    add_column :articles, :image, :string
  end
end
