class TagsController < ApplicationController
  # タグ名サジェストAPI
  def autocomplete
    term = params[:term].to_s
    tags = Tag.where('name LIKE ?', "%#{term}%").limit(10).pluck(:name)
    render json: tags
  end
end
