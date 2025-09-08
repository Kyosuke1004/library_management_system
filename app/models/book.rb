class Book < ApplicationRecord
  has_many :loans, dependent: :destroy # 本が削除されたときに関連する貸出記録も削除
  has_many :users, through: :loans # 本を借りたユーザーを取得するための関連付け

  def available?
    loans.currently_borrowed.empty?
  end
end
