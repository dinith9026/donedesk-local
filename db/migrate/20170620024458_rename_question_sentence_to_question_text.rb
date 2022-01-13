class RenameQuestionSentenceToQuestionText < ActiveRecord::Migration[5.0]
  def change
    rename_column :questions, :sentence, :text
  end
end
