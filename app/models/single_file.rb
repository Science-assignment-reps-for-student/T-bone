class SingleFile < ApplicationRecord
  belongs_to :user
  belongs_to :homework

  def self.create_single_file(user_id, homework_id, files, update)
    homework = Homework.find_by_id(homework_id)
    user = User.find_by_id(user_id)

    return 404 unless homework
    return 404 if homework.homework_type != 0 && homework.homework_type != 2

    unless update
      unless user.single_files.find_by_homework_id(homework.id).blank?
        return 409
      end
    end

    FileUtils.mkdir_p("#{ENV['SINGLE_FILE_PATH']}/#{homework.id}")
    if files.length == 1
      file_name = if homework.homework_type.zero?
                    "[개인][#{homework.homework_title}] #{user.user_number}_#{user.user_name}.#{files.keys[0].split('.')[-1]}"
                  else
                    "[실험][#{homework.homework_title}] #{user.user_number}_#{user.user_name}.#{files.keys[0].split('.')[-1]}"
                  end

      path = "#{ENV['SINGLE_FILE_PATH']}/#{homework.id}/#{user_id}/#{file_name}"

      created_file = homework.single_files.create!(user_id: user.id,
                                                   source: ApplicationController.upload_file(files.values[0], path),
                                                   file_name: file_name)

      ApplicationController.late?(user.user_number / 100 - 10,
                                  created_file,
                                  homework)
    else
      files.each do |file_name, file|
        path = "#{ENV['SINGLE_FILE_PATH']}/#{homework.id}/#{user_id}/#{file_name}"
        created_file = homework.single_files.create(user_id: user.id,
                                                    source: ApplicationController.upload_file(file, path),
                                                    file_name: file_name)

        ApplicationController.late?(user.user_number / 100 - 10,
                                    created_file,
                                    homework)
      end
    end
    false
  end
end
