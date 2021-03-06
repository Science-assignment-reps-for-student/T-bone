class CommentsController < ApplicationController
  before_action :set_board, except: :destroy
  before_action :jwt_required

  def show
    return render status: :not_found unless @board

    response = []
    @board.comments.each do |comment|
      response << {
        comment_id: comment.id,
        writer: "#{comment.user.user_number} #{comment.user.user_name}",
        description: comment.description,
        created_at: comment.created_at,
        updated_at: comment.updated_at
      }
    end
    render json: response
  end

  def create
    requires(:description)

    if current_user.user_type.zero? &&
       @board.class_number != current_user.user_number / 100 - 10
      return render status: :forbidden
    end

    comment = @board.comments.create!(user_id: @payload['user_id'],
                                      description: params[:description])
    render json: {
      comment_id: comment.id,
      writer: comment.user.user_name,
      description: comment.description,
      created_at: comment.created_at,
      updated_at: comment.updated_at
    }, status: :created
  end

  def destroy
    comment = Comment.find_by_id(params[:cocomment_id])
    return render status: :not_found unless comment

    if comment.user != current_user && current_user.user_type.zero?
      return render status: :forbidden
    end

    comment.destroy!
    render status: :ok
  end

  private

  def set_board
    requires(:board_id)
    @board = Board.find_by_id(params[:board_id])
  end
end
