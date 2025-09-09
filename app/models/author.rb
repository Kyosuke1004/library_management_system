class Author < ApplicationRecord
  has_many :authorships, dependent: :destroy # 本が削除されたときに関連する著者情報も削除
  has_many :books, through: :authorships # 本の著者を取得するための関連付け

  validates :name, presence: true
end
