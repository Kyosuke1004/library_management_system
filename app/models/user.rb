class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :loans, dependent: :destroy # ユーザーが削除されたときに関連する貸出記録も削除
  has_many :books, through: :loans # ユーザーが借りた本を取得するための関連付け

  enum :role, { general: 0, admin: 1 }
end
