class ChangeDefaultForPublishedInArticles < ActiveRecord::Migration[8.0]
  def change
    change_column_default :articles, :published, true
  end
end
