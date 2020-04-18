class CommentsController < ApplicationController
  before_action :jwt_required

  def show
    render json: Board.find_by_id(params[:board_id]).comments
  end

  def create
    requires(:description)

    if current_user.user_type.zero? &&
       @board.class_number != current_user.user_number / 100 - 10
      return render status: :forbidden
    end

    @board.comments.create!(user_id: @payload['user_id'],
                            description: params[:description])
    render status: :created
  end

  def destroy
    Comment.find_by_id(params[:comment_id]).destroy!
  end
end
