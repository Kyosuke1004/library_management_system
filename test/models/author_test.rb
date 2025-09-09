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
    @author = Author.new(name: 'テスト著者')
    @book = Book.new(title: 'テスト本', isbn: '1234567890', published_year: 2024, publisher: 'テスト出版')
    @author.save!
    @book.save!
    @authorship = @author.authorships.create!(book: @book)
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
