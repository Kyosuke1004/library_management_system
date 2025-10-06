require 'test_helper'

class AuthorTest < ActiveSupport::TestCase
  def setup
    @author = Author.new(name: 'テスト著者')
  end

  # バリデーションテスト
  test 'should be valid' do
    assert @author.valid?
  end

  test 'name should be present' do
    @author.name = ''
    assert_not @author.valid?
  end
end

# 関連付けテスト用の別クラス
class AuthorAssociationTest < ActiveSupport::TestCase
  def setup
    @author = Author.create!(name: "テスト著者_#{SecureRandom.hex(4)}")
    @book = Book.create!(
      title: 'テスト本',
      isbn: SecureRandom.hex(8),
      published_year: 2024,
      publisher: 'テスト出版',
      authors: [@author]
    )
    @authorship = @book.authorships.first
  end

  test 'should have many authorships' do
    assert_includes @author.authorships, @authorship
  end

  test 'should have many books through authorships' do
    assert_includes @author.books, @book
  end

  test 'should destroy associated authorships when author is destroyed' do
    assert_difference 'Authorship.count', -1 do
      @author.destroy
    end
  end
end
