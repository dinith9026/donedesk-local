class AddSummaryToDocuments < ActiveRecord::Migration[5.0]
  def change
    add_column :documents, :summary, :string
  end
end
