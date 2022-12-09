class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @book = Book.find(params[:id])
    @book_new = Book.new
    @comment = BookComment.new
  end

  def index
    @book = Book.new

    # 本の投稿一覧ページで、過去一週間でいいねの合計カウントが多い順に投稿を表示
    to  = Time.current.at_end_of_day
    from  = (to - 6.day).at_beginning_of_day

    # 検証用
    @to  = Time.current.at_end_of_day
    @from  = (to - 6.day).at_beginning_of_day

    # 過去一週間のいいねが多い順に表示
    # @books = Book.all.sort_by {|x| x.favorites.where(created_at: from..to).count}.reverse
    # @books = Book.includes(:favorites).sort_by {|x| x.favorites.where(created_at: from..to).count}.reverse
    @books = Book.includes(:favorites).sort_by {|x| x.favorites.where(created_at: from...to).size}.reverse

    # 正解サンプルコード
    # @books = Book.all.sort {|a,b|
    #   b.favorites.where(created_at: from...to).size <=>
    #   a.favorites.where(created_at: from...to).size
    # }

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
