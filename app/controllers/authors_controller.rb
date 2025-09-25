class AuthorsController < ApplicationController
  def autocomplete
    authors = Author.where('name LIKE ?', "%#{params[:term]}%").limit(10)
    render json: authors.pluck(:name)
  end
end
