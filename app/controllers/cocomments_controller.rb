class CocommentsController < ApplicationController
  before_action :set_comment
  before_action :jwt_required

  def show
    return render status: :not_found unless @comment

    response = []
    @comment.cocomments.each do |cocomment|
      response << {
        cocomment_id: cocomment.id,
        writer: cocomment.user.user_name,
        description: cocomment.description,
        created_at: cocomment.created_at,
        updated_at: cocomment.updated_at
      }
    end
    render json: response
  end

  def create
    requires(:description, :comment_id)

    if current_user.user_type.zero? &&
       @comment.class_number != current_user.user_number / 100 - 10
      return render status: :forbidden
    end

    cocomment = @comment.cocomments.create!(user_id: @payload['user_id'],
                                            description: params[:description])
    render json: {
      cocomment_id: cocomment.id,
      writer: cocomment.user.user_name,
      description: cocomment.description,
      created_at: cocomment.created_at,
      updated_at: cocomment.updated_at
    }, status: :created
  end

  def destroy
    Cocomment.find_by_id(params[:cocomment_id]).destroy!
  end

  private

  def set_comment
    @comment = Comment.find_by_id(params[:comment_id])
  end
end
