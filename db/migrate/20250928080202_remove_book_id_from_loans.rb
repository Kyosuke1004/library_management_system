class RemoveBookIdFromLoans < ActiveRecord::Migration[7.1]
  def change
    remove_column :loans, :book_id, :integer
  end
end
