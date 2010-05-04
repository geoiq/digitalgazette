class AddAssetPageMetadata < ActiveRecord::Migration
  def self.up
    add_column :pages, :publisher, :string
    add_column :pages, :year_published, :integer
    add_column :pages, :methodology, :text
    add_column :pages, :sample_size, :string
    add_column :pages, :certification, :boolean
  end

  def self.down
    remove_column :pages, :certification
    remove_column :pages, :sample_size
    remove_column :pages, :methodology
    remove_column :pages, :year_published
    remove_column :pages, :publisher
  end
end
