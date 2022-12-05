class BookCommentsController < ApplicationController
  def create
    @book = Book.find(params[:book_id])
    comment = current_user.book_comments.new(book_comment_params)
    comment.book_id = @book.id
    if comment.save
      flash.now[:notice] = 'コメントを投稿しました'
      render :book_comments
    else
      render 'books/show'
    end
  end

  def destroy
    BookComment.find(params[:id]).destroy
    flash.now[:notice] = 'コメントを削除しました'
    @book = Book.find(params[:book_id]) # Ajax処理用
    render :book_comments
  end

  private
  def book_comment_params
    params.require(:book_comment).permit(:comment)
  end
end
