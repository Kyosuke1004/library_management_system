class UsersController < ApplicationController
  before_action :require_admin

  def index
    @users = if params[:search].present?
               User.where('email LIKE ?', "%#{params[:search]}%")
             else
               User.all
             end
  end

  private

  def require_admin
    redirect_to root_path, alert: '管理者のみアクセス可能です。' unless current_user&.admin?
  end
end
