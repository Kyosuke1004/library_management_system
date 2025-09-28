class ChangeBookItemIdToNotNullInLoans < ActiveRecord::Migration[7.1]
  def change
    change_column_null :loans, :book_item_id, false
  end
end
