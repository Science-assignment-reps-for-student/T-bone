class ExcelFile < ApplicationRecord
  belongs_to :homework

  def self.create_excel(homework_id)
    homework = Homework.find_by_id(homework_id)
    book = Spreadsheet::Workbook.new
    sheets = [book.create_worksheet(name: '1반'),
              book.create_worksheet(name: '2반'),
              book.create_worksheet(name: '3반'),
              book.create_worksheet(name: '4반')]

    set_form(sheets)

    Team.where(homework_id: homework_id).order(team_name: :asc).each do |team|
      class_number = team.users.last.user_number / 100 - 10

      team.users.order(user_number: :asc).each_with_index do |user, index|
        row = index * 2 + 1
        sheets[class_number - 1].row(row)[0] = team.team_name
        sheets[class_number - 1].row(row)[1] = user.user_number
        sheets[class_number - 1].row(row)[2] = user.user_name
        sheets[class_number - 1].row(row)[3] = team.multi_files
                                                   .last
                                                   .created_at
                                                   .strftime('%Y-%m-%d %T')
        mutual_evaluation = MutualEvaluation.joins(:user)
                                            .where(homework_id: homework_id,
                                                   target_id: user.id)
                                            .order(user_number: :asc)

        communication = mutual_evaluation.map(&:communication)
        cooperation = mutual_evaluation.map(&:cooperation)

        sheets[class_number - 1].row(row).push(communication,
                                               communication.sum)
        sheets[class_number - 1].row(row + 1).push(cooperation,
                                                   cooperation.sum)

        self_evaluation = user.self_evaluations
                              .find_by_homework_id(homework.id)

        next unless self_evaluation

        sheets[class_number - 1].row(row)[10] = self_evaluation.scientific_accuracy
        sheets[class_number - 1].row(row)[11] = self_evaluation.communication
        sheets[class_number - 1].row(row)[12] = self_evaluation.attitude
      end
    end

    homework_type = case homework.homework_type
                    when 0
                      '개인'
                    when 1
                      '팀'
                    when 2
                      '실험'
                    end

    file_name = "'[#{homework_type}] #{homework.homework_title}.xls'"
    path = "#{ENV['EXCEL_FILE_PATH']}/#{homework.id}/#{file_name}"

    FileUtils.mkdir_p("#{ENV['EXCEL_FILE_PATH']}/#{homework.id}")

    book.write(path)
    ExcelFile.create!(homework_id: homework.id,
                      source: path,
                      file_name: file_name)
  end

  def self.set_form(sheets)
    sheets.each do |sheet|
      sheet.default_format = Spreadsheet::Format.new(horizontal_align: :center)
      sheet.merge_cells(0, 10, 0, 12)
      (10..12).each { |i| sheet.merge_cells(1, i, 2, i) }
      (0..12).each do |i|
        sheet.merge_cells(0, i, 2, i) unless (10..12).include?(i)
        (2..22).each { |j| sheet.merge_cells(j * 2 - 1, i, j * 2, i) unless (4..9).include?(i) }
      end

      sheet.row(0).push('조',
                        '학번',
                        '이름',
                        '제출 일시',
                        '평가 종류',
                        '모둠원 A',
                        '모둠원 B',
                        '모둠원 C',
                        '모둠원 D',
                        '모둠 합산',
                        '자기평가')
      sheet.row(1)[10] = '과학적 정확성'
      sheet.row(1)[11] = '의사소통'
      sheet.row(1)[12] = '흥미/태도(협력)'
      (3..44).each do |i|
        sheet.row(i)[4] = if i.odd?
                            '의사소통'
                          else
                            '공동체(협력)'
                          end
      end
    end

    sheets
  end


end
