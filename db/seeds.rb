# 既存データをクリア
Loan.destroy_all
Authorship.destroy_all
Author.destroy_all
User.destroy_all
Book.destroy_all

# Author サンプルデータを先に作成
authors = Author.create!([
  { name: "Michael Hartl" },
  { name: "Peter J. Jones" }, 
  { name: "Dustin Boswell" },
  { name: "Trevor Foucher" },
  { name: "Douglas Crockford" }
])

# 本と著者の関連付けを同時に作成
created_books = []

# 本1: Ruby on Rails チュートリアル
book1 = Book.new(
  title: "Ruby on Rails チュートリアル",
  isbn: "9784274069727",
  published_year: 2019,
  publisher: "オーム社"
)
book1.authors = [authors[0]]  # 保存前に関連付け
book1.save!
created_books << book1

# 本2: エフェクティブ Ruby
book2 = Book.new(
  title: "エフェクティブ Ruby", 
  isbn: "9784798139821",
  published_year: 2014,
  publisher: "翔泳社"
)
book2.authors = [authors[1]]
book2.save!
created_books << book2

# 本3: リーダブルコード（共著）
book3 = Book.new(
  title: "リーダブルコード",
  isbn: "9784873115658",
  published_year: 2012,
  publisher: "オライリー・ジャパン"
)
book3.authors = [authors[2], authors[3]]  # 共著
book3.save!
created_books << book3

# 本4: プログラマが知るべき97のこと
book4 = Book.new(
  title: "プログラマが知るべき97のこと",
  isbn: "9784873114798",
  published_year: 2010,
  publisher: "オライリー・ジャパン"
)
book4.authors = [authors[3]]
book4.save!
created_books << book4

# 本5: JavaScript: The Good Parts
book5 = Book.new(
  title: "JavaScript: The Good Parts",
  isbn: "9784873113913", 
  published_year: 2008,
  publisher: "オライリー・ジャパン"
)
book5.authors = [authors[4]]
book5.save!
created_books << book5

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
    book: created_books[0],  # Rails チュートリアル
    borrowed_at: 3.days.ago
  },
  {
    user: users[1],  # bob
    book: created_books[1],  # エフェクティブ Ruby
    borrowed_at: 1.week.ago
  }
])

# 返却済みの本（returned_at が設定されている）
Loan.create!([
  {
    user: users[0],  # alice
    book: created_books[2],  # リーダブルコード
    borrowed_at: 2.weeks.ago,
    returned_at: 1.week.ago
  },
  {
    user: users[2],  # charlie
    book: created_books[3],  # プログラマが知るべき97のこと
    borrowed_at: 1.month.ago,
    returned_at: 3.weeks.ago
  }
])

puts "✅ サンプルデータの作成が完了しました！"
puts "📚 本: #{Book.count}冊"
puts "👤 著者: #{Author.count}人"
puts "👥 ユーザー: #{User.count}人"  
puts "📋 貸出記録: #{Loan.count}件"
puts "🔗 著者関連: #{Authorship.count}件"