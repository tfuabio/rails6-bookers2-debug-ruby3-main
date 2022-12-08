class SearchesController < ApplicationController
  before_action :authenticate_user!

  def search
    @range = params[:range] # 検索画面で使用
    w = params[:word]
    s = params[:search]

    # 検索方法によって分岐
    if s ==  "partial_match"
      @word = "「#{w}」を含む"
      w = "%#{w}%"
    elsif s == "forward_match"
      @word = "「#{w}」から始まる"
      w = "#{w}%"
    elsif s == "backward_match"
      @word = "「#{w}」で終わる"
      w = "%#{w}"
    else
      @word = "「#{w}」に完全一致"
    end

    # 検索対象によって分岐
    if @range == "User"
      @users = User.where("name LIKE?", w)
    else
      @books = Book.where("title LIKE?", w)
    end
  end
end
