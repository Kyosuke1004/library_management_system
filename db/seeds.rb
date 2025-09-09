# 既存データをクリア
Loan.destroy_all
User.destroy_all
Book.destroy_all

# Book サンプルデータ
books = Book.create!([
  {
    title: "Ruby on Rails チュートリアル",
    isbn: "9784274069727",
    published_year: 2019,
    publisher: "オーム社"
  },
  {
    title: "エフェクティブ Ruby",
    isbn: "9784798139821",
    published_year: 2014,
    publisher: "翔泳社"
  },
  {
    title: "リーダブルコード",
    isbn: "9784873115658",
    published_year: 2012,
    publisher: "オライリー・ジャパン"
  },
  {
    title: "プログラマが知るべき97のこと",
    isbn: "9784873114798",
    published_year: 2010,
    publisher: "オライリー・ジャパン"
  },
  {
    title: "JavaScript: The Good Parts",
    isbn: "9784873113913",
    published_year: 2008,
    publisher: "オライリー・ジャパン"
  }
])

# User サンプルデータ
users = User.create!([
  {
    email: "alice@example.com",
    password: "password123",
    password_confirmation: "password123"
  },
  {
    email: "bob@example.com",
    password: "password123",
    password_confirmation: "password123"
  },
  {
    email: "charlie@example.com",
    password: "password123",
    password_confirmation: "password123"
  }
])

# Loan サンプルデータ
# 現在借りている本（returned_at が nil）
Loan.create!([
  {
    user: users[0],  # alice
    book: books[0],  # Rails チュートリアル
    borrowed_at: 3.days.ago
  },
  {
    user: users[1],  # bob
    book: books[1],  # エフェクティブ Ruby
    borrowed_at: 1.week.ago
  }
])

# 返却済みの本（returned_at が設定されている）
Loan.create!([
  {
    user: users[0],  # alice
    book: books[2],  # リーダブルコード
    borrowed_at: 2.weeks.ago,
    returned_at: 1.week.ago
  },
  {
    user: users[2],  # charlie
    book: books[3],  # プログラマが知るべき97のこと
    borrowed_at: 1.month.ago,
    returned_at: 3.weeks.ago
  }
])

# Author サンプルデータ
authors = Author.create!([
  { name: "Michael Hartl" },
  { name: "Peter J. Jones" },
  { name: "Dustin Boswell" },
  { name: "和田卓人" }
])

# 既存の本に著者を関連付け
if Book.exists? && Author.exists?
  rails_book = Book.find_by(title: "Ruby on Rails チュートリアル")
  rails_book&.authors << authors[0]
  
  ruby_book = Book.find_by(title: "エフェクティブ Ruby")
  ruby_book&.authors << authors[1]
  
  readable_book = Book.find_by(title: "リーダブルコード")
  readable_book&.authors << authors[2]
  
  programmer_book = Book.find_by(title: "プログラマが知るべき97のこと")
  programmer_book&.authors << authors[3]
end