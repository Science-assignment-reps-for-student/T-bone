class CocomentsController < ApplicationController
  before_action :set_comment
  before_action :jwt_required

  def show
    return render status: :not_found unless @comment

    render json: @comment.cocomments
  end

  def create
    requires(:description, :comment_id)

    if current_user.user_type.zero? &&
       @comment.class_number != current_user.user_number / 100 - 10
      return render status: :forbidden
    end

    @comment.cocomments.create!(user_id: @payload['user_id'],
                                description: params[:description])
    render status: :created
  end

  def destroy
    Cocomment.find_by_id(params[:cocomment_id]).destroy!
  end

  private

  def set_comment
    @comment = Comment.find_by_id(params[:comment_id])
  end
end
