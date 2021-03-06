class BoardsController < ApplicationController
  before_action :set_board, only: %i[show update destroy]
  before_action :jwt_required

  # GET /boards
  def index
    board = if current_user.user_type.zero?
              Board.where(class_number: current_user.user_number / 100 - 10)
            else
              Board.where(class_number: params[:class_number])
            end

    response = []
    board.each do |board|
      json = {}

      json['board_id'] = board.id
      json['writer'] = board.user.user_name
      json['title'] = board.title
      json['created_at'] = board.created_at
      json['updated_at'] = board.updated_at
      json['class'] = board.class_number

      response << json
    end

    render json: response
  end

  # GET /boards/1
  def show
    response = {
      board_id: @board.id,
      writer: @board.user.user_name,
      title: @board.title,
      description: @board.description,
      created_at: @board.created_at,
      updated_at: @board.updated_at,
      class: @board.class_number,
      comment_id: @board.comment_ids,
      file_id: @board.image_file_ids,
      is_mine: @board.user == current_user
    }
    if current_user.user_type.zero?
      if @board.class_number == current_user.user_number / 100 - 10
        render json: response
      else
        render status: :forbidden
      end
    else
      render json: response
    end
  end

  # POST /boards
  def create
    if current_user.user_type.zero?
      requires(:title, :description)
    else
      requires(:title, :description, :class_number)
    end

    files = {}
    params[:file]&.each do |file|
      files[file.original_filename] = File.open(file)
      unless %w[.jpg .jpeg .png].include?(File.extname(file))
        return render status: 415
      end
    end

    @board = if current_user.user_type.zero?
               current_user.boards.create!(title: params[:title],
                                           description: params[:description],
                                           class_number: current_user.user_number / 100 - 10)
             else
               current_user.boards.create!(title: params[:title],
                                           description: params[:description],
                                           class_number: params[:class_number])
             end
    ImageFile.create_image_file(@board.id, files) unless files.empty?

    render status: :created
  end

  # PATCH/PUT /boards/1
  def update
    if @board.user != current_user && current_user.user_type.zero?
      render status: :forbidden
    end

    @board.update(title: params[:title], description: params[:description])
    render status: :ok
  end

  # DELETE /boards/1
  def destroy
    if @board.user != current_user && current_user.user_type.zero?
      render status: :forbidden
    end

    @board.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_board
    @board = Board.find(params[:board_id])
  end
end
