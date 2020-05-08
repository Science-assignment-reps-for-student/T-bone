class MultiFile < ApplicationRecord
  belongs_to :team
  belongs_to :homework

  def self.create_multi_file(user_id, homework_id, files, update)
    homework = Homework.find_by_id(homework_id)
    class_num = User.find_by_id(user_id).user_number / 100 - 10
    team = Team.find_by_leader_id_and_homework_id(user_id, homework.id)

    return 404 unless homework
    return 404 unless homework.homework_type == 1
    return 403 unless team

    unless update
      return 409 unless team.multi_files.blank?
    end

    FileUtils.mkdir_p("#{ENV['MULTI_FILE_PATH']}/#{homework.id}")
    if files.length == 1
      file_name = "[팀][#{homework.homework_title}] #{class_num}반_#{team.team_name}조.#{files.keys[0].split('.')[-1]}"
      path = "#{ENV['MULTI_FILE_PATH']}/#{homework.id}/#{user_id}/#{file_name}"

      created_file = homework.multi_files.create(team_id: team.id,
                                                 source: ApplicationController.upload_file(files.values[0], path),
                                                 file_name: file_name)

      ApplicationController.late?(class_num,
                                  created_file,
                                  homework)
    else
      files.each do |file_name, file|
        path = "#{ENV['MULTI_FILE_PATH']}/#{homework.id}/#{user_id}/#{file_name}"
        created_file = homework.multi_files.create(team_id: team.id,
                                                   source: ApplicationController.upload_file(file, path),
                                                   file_name: file_name)

        ApplicationController.late?(class_num,
                                    created_file,
                                    homework)
      end
    end
    false
  end
end
