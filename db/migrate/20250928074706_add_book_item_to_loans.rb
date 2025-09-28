class AddBookItemToLoans < ActiveRecord::Migration[7.1]
  def change
    add_reference :loans, :book_item, null: true, foreign_key: true
  end
end
