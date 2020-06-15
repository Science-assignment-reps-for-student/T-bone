class ExcelFile < ApplicationRecord
  belongs_to :homework

  def self.create_excel(homework_id)
    homework = Homework.find_by_id(homework_id)

    book = Spreadsheet::Workbook.new
    format_default = Spreadsheet::Format.new(horizontal_align: :center)
    format_unsubmit = Spreadsheet::Format.new(horizontal_align: :center,
                                              pattern_fg_color: :yellow)
    format_extra = Spreadsheet::Format.new(horizontal_align: :center,
                                           pattern_fg_color: :red)

    sheets = [book.create_worksheet(name: '1반'),
              book.create_worksheet(name: '2반'),
              book.create_worksheet(name: '3반'),
              book.create_worksheet(name: '4반')]

    sheets.each do |sheet|
      sheet.default_format = format_default
      sheet.row(0)[5] = '자기 평가'
      sheet.row(0)[8] = '상호 평가'
      sheet.merge_cells(0, 0, 0, 4)
      sheet.merge_cells(0, 5, 0, 7)
      sheet.merge_cells(0, 8, 0, 9)
      sheet.row(1).push('조', '학번', '이름', '제출 일시', '지각 여부', '과학적 정확성', '의사소통', '흥미/태도(협력)', '의사소통', '공동체(협력)')
    end

    row_set = [2, 2, 2, 2]
    User.where(user_type: 0).order(user_number: :asc).each do |user|
      class_number = user.user_number / 100 - 10

      row = row_set[class_number - 1]
      user_team = nil
      homework.teams.each do |team|
        team.members.each do |member|
          user_team = team if member.user_id == user.id
        end
      end

      unless user_team
        sheets[class_number - 1].default_format = format_extra
        sheets[class_number - 1].row(row).push(nil,
                                               user.user_number,
                                               user.user_name)
        row_set[class_number - 1] += 1
        next
      end

      submit_file = if homework.homework_type == 1
                      homework.multi_files.where(team_id: user_team.id)
                    else
                      homework.single_files.where(user_id: user.id)
                    end

      begin
        self_evaluation = user.self_evaluations.find_by_homework_id(homework.id)
        scientific_accuracy = self_evaluation.scientific_accuracy
        self_communication = self_evaluation.communication
        attitude = self_evaluation.attitude
      rescue NoMethodError
        scientific_accuracy = nil
        self_communication = nil
        attitude = nil
      end

      communication = ''
      cooperation = ''

      MutualEvaluation.where(target_id: user.id, homework_id: homework.id).each do |evaluation|
        communication = "#{evaluation.communication.to_i} / #{(user_team.members.count - 1) * 3}"
        cooperation = "#{evaluation.cooperation.to_i} / #{(user_team.members.count - 1) * 3}"
      end

      if submit_file.blank?
        sheets[class_number - 1].default_format = format_unsubmit
        sheets[class_number - 1].row(row).push(user_team.team_name,
                                               user.user_number,
                                               user.user_name,
                                               nil,
                                               nil,
                                               scientific_accuracy,
                                               self_communication,
                                               attitude,
                                               communication,
                                               cooperation)
      else
        sheets[class_number - 1].default_format = format_default
        sheets[class_number - 1].row(row).push(user_team.team_name,
                                               user.user_number,
                                               user.user_name,
                                               submit_file.last.created_at,
                                               submit_file.last.late,
                                               scientific_accuracy,
                                               self_communication,
                                               attitude,
                                               communication,
                                               cooperation)
      end
      row_set[class_number - 1] += 1
    end
    path = "#{ENV['EXCEL_FILE_PATH']}/#{homework.id}/#{homework.id}.xls"

    FileUtils.mkdir_p("#{ENV['EXCEL_FILE_PATH']}/#{homework.id}")

    book.write(path)
    ExcelFile.create!(homework_id: homework.id,
                      source: path,
                      file_name: "#{homework.id}.xls")
  end
end
