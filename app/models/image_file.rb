class ImageFile < ApplicationRecord
  belongs_to :board

  def self.create_image_file(board_id, files)
    board = Board.find_by_id(board_id)

    FileUtils.mkdir_p("#{ENV['IMAGE_FILE_PATH']}/#{board.id}")

    files.each do |file_name, file|
      path = "#{ENV['IMAGE_FILE_PATH']}/#{board.id}/#{file_name}"
      board.image_files.create!(source: ApplicationController.upload_file(file, path),
                                path: file_name)
    end
  end
end
