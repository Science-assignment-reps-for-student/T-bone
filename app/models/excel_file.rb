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

    row = 2
    User.where(user_type: 0).order(user_number: :desc).each do |user|
      class_number = user.user_number / 100 - 10
      team_id = homework.teams.each do |team|
        return team.id if team.member_ids.include?(user.id)
      end
      user_team = Team.find_by_id(team_id)
      self_evaluation = user.self_evaluations.find_by_homework_id(homework_id)

      communication = ''
      cooperation = ''

      MutualEvaluation.where(target_id: user.id, homework_id: homework_id).each do |evaluation|
        communication = "#{evaluation.communication} / #{user_team.members.count * 3}"
        cooperation = "#{evaluation.cooperation} / #{user_team.members.count * 3}"
      end

      if user_team.nil?
        sheets[class_number - 1].default_format = format_extra
        sheets[class_number - 1].row(row).push(nil,
                                               user.user_number,
                                               user.user_name)
      elsif user_team.multi_files.blank?
        sheets[class_number - 1].default_format = format_unsubmit
        sheets[class_number - 1].row(row).push(user_team.team_name,
                                               user.user_number,
                                               user.user_name)
      elsif MutualEvaluation.find_by_homework_id_and_user_id(homework_id, user.id).nil? &&
            SelfEvaluation.find_by_homework_id_and_user_id(homework_id, user.id).nil?
        sheets[class_number - 1].default_format = format_unsubmit
        sheets[class_number - 1].row(row).push(user_team.team_name,
                                               user.user_number,
                                               user.user_name,
                                               homework.created_at,
                                               user_team.multi_files.last.late)
      else
        sheets[class_number - 1].row(row).push(user_team.team_name,
                                               user.user_number,
                                               user.user_name,
                                               homework.created_at,
                                               user_team.multi_files.last.late,
                                               self_evaluation.scientific_accuracy,
                                               self_evaluation.communication,
                                               self_evaluation.attitude,
                                               communication,
                                               cooperation)
      end
    end
    path = "#{ENV['EXCEL_FILE_PATH']}/#{homework.id}/[자기/상호평가]#{homework.homework_title}.xls"

    FileUtils.mkdir_p("#{ENV['EXCEL_FILE_PATH']}/#{homework.id}")
    File.new(path)

    book.write(path)
    homework.excel_file.create!(source: path,
                                file_name: "[자기/상호평가]#{homework.homework_title}.xls")
  end
end
