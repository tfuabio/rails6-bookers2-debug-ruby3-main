class BooksController < ApplicationController
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @book = Book.find(params[:id])
    @book_new = Book.new
    @comment = BookComment.new
  end

  def index
    @book = Book.new

    # 過去１週間でいいねの多い順にしたい
    # @books = Book.all
    to  = Time.current.at_end_of_day
    from  = (to - 6.day).at_beginning_of_day

    # 全ての投稿をいいねの多い順にする
    # @books = Book.all.sort_by {|x| x.favorites.count}.reverse
    # @books = Book.includes(:favorites).sort_by {|x| x.favorites.count}.reverse

    # 過去一週間の投稿だけを表示
    # @books = Book.where(created_at: from..to)

    # 過去一週間の投稿だけをいいねの多い順に表示
    @books = Book.where(created_at: from..to).sort_by {|x| x.favorites.count}.reverse

    # 過去一週間の投稿をいいねの多い順に表示？正解か不明。
    # @books = Book.includes(:favorites).sort_by {|x| x.favorites.where(created_at: from..to).count}.reverse
    # @books = Book.all.sort_by {|x| x.favorites.where(created_at: from..to).count}.reverse

    # コピペコード
    # @books = Book.includes(:favorited_users).
    #   sort {|a,b|
    #     b.favorited_users.includes(:favorites).where(created_at: from...to).size <=>
    #     a.favorited_users.includes(:favorites).where(created_at: from...to).size
    #   }
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    @books = Book.all # ajax対応用
    if @book.save
      flash.now[:notice] = 'You have created book successfully.'
      render :books
    else
      render :error
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book), notice: 'You have updated book successfully.'
    else
      render "edit"
    end
  end

  def destroy
    book = Book.find(params[:id])
    book.destroy
    redirect_to books_path, notice: 'You have deleted book successfully.'
  end

  private

  def book_params
    params.require(:book).permit(:title, :body)
  end

  def ensure_correct_user
    book = Book.find(params[:id])
    unless book.user_id == current_user.id
      redirect_to books_path
    end
  end
end
