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

    row_set = [3, 3, 3, 3]
    Team.where(homework_id: homework_id).order(team_name: :asc).each do |team|
      class_number = team.users.last.user_number / 100 - 10
      team.users.order(user_number: :asc).each do |user|
        row = row_set[class_number - 1]
        row_set[class_number - 1] += 3

        sheets[class_number - 1].row(row)[0] = team.team_name
        sheets[class_number - 1].row(row)[1] = user.user_number
        sheets[class_number - 1].row(row)[2] = user.user_name
        sheets[class_number - 1].row(row)[3] = team.multi_files
                                                   .last
                                                   .created_at
                                                   .strftime("%Y-%m-%d\n%T")
        mutual_evaluation = MutualEvaluation.joins(:user)
                                            .where(homework_id: homework_id,
                                                   target_id: user.id)
                                            .order(user_number: :asc)

        sheets[class_number - 1].row(row)[5..8] =
          mutual_evaluation.map do |evaluation|
            evaluation.user.user_name
          end
        sheets[class_number - 1].row(row + 1)[5..8] = mutual_evaluation.map(&:communication)
        sheets[class_number - 1].row(row + 2)[5..8] = mutual_evaluation.map(&:cooperation)
        sheets[class_number - 1].row(row + 1)[9] = mutual_evaluation.map(&:communication)
                                                                .sum
        sheets[class_number - 1].row(row + 2)[9] = mutual_evaluation.map(&:cooperation)
                                                                    .sum

        self_evaluation = user.self_evaluations
                              .find_by_homework_id(homework.id)

        sheets[class_number - 1].row(row)[10] = mutual_evaluation.map(&:communication)
                                                                 .sum +
                                                mutual_evaluation.map(&:cooperation)
                                                                 .sum

        next unless self_evaluation

        sheets[class_number - 1].row(row)[11] = self_evaluation.scientific_accuracy
        sheets[class_number - 1].row(row)[12] = self_evaluation.communication
        sheets[class_number - 1].row(row)[13] = self_evaluation.attitude
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

  def self.singular_excel(homework_id)
    homework = Homework.find_by_id(homework_id)

    book = Spreadsheet::Workbook.new
    sheets = [book.create_worksheet(name: '1반'),
              book.create_worksheet(name: '2반'),
              book.create_worksheet(name: '3반'),
              book.create_worksheet(name: '4반')]

    sheets.each do |sheet|
      sheet.default_format = Spreadsheet::Format.new(horizontal_align: :center)
      sheet.row(0).push('학번', '이름', '제출 시각')
    end

    row_set = [1, 1, 1, 1]
    homework.single_files.each do |single_file|
      user = single_file.user
      class_number = user.user_number / 100 - 10
      row = row_set[class_number - 1]
      row_set[class_number - 1] += 1

      sheets[class_number - 1].row(row).push(user.user_number,
                                             user.user_name,
                                             single_file.created_at
                                                        .strftime("%Y-%m-%d\n%T"))
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
      sheet.merge_cells(0, 11, 0, 13)
      (11..13).each { |i| sheet.merge_cells(1, i, 2, i)}
      (0..13).each do |i|
        sheet.merge_cells(0, i, 2, i) unless (11..13).include?(i)
        (1..22).each { |j| sheet.merge_cells(j * 3, i, j * 3 + 2, i) unless (4..9).include?(i)}
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
                        '총 합산',
                        '자기평가')
      sheet.row(1)[11] = '과학적 정확성'
      sheet.row(1)[12] = '의사소통'
      sheet.row(1)[13] = '흥미/태도(협력)'
      (3..68).each do |i|
        sheet.row(i)[4] = if i % 3 == 0
                            '평가자'
                          elsif i % 3 == 1
                            '의사소통'
                          else
                            '공동체(협력)'
                          end
      end
    end

    sheets
  end


end
