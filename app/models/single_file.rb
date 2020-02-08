class SingleFile < ApplicationRecord
  belongs_to :user
  belongs_to :homework

  def self.create_single_file(user_id, homework_id, files, update)
    homework = Homework.find_by_id(homework_id)
    user = User.find_by_id(user_id)

    return 404 unless homework

    unless update
      return 409 unless homework.single_files.blank?
    end

    FileUtils.mkdir_p("#{ENV['SINGLE_FILE_PATH']}/#{homework.id}")
    if files.length == 1
      if homework.homework_type.zero?
        path = "#{ENV['SINGLE_FILE_PATH']}/#{homework.id}/[개인][#{homework.homework_title}] #{user.user_number}_#{user.user_name}.hwp"
        file_name = "[개인][#{homework.homework_title}] #{user.user_number}_#{user.user_name}.hwp"
      else
        path = "#{ENV['SINGLE_FILE_PATH']}/#{homework.id}/[실험][#{homework.homework_title}] #{user.user_number}_#{user.user_name}.hwp"
        file_name = "[실험][#{homework.homework_title}] #{user.user_number}_#{user.user_name}.hwp"
      end

      created_file = homework.single_files.create!(user_id: user.id,
                                                   source: ApplicationController.upload_file(files.values[0], path),
                                                   file_name: file_name)

      ApplicationController.late?(user.user_number / 100 - 10,
                                  created_file,
                                  homework)
    else
      files.each do |file_name, file|
        path = "#{ENV['SINGLE_FILE_PATH']}/#{homework.id}/#{file_name}"
        created_file = homework.multi_files.create(user_id: user.id,
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
