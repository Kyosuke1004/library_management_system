class BookItem < ApplicationRecord
  belongs_to :book
  has_many :loans, dependent: :destroy
end
