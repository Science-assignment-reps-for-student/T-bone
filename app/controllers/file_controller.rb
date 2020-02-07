class FileController < ApplicationController
  before_action :jwt_required

  def showOne
    requires(homework_type: Integer, file_id: Integer)

    payload = @@jwt_base.get_jwt_payload(request.authorization[7..])

    render status: 400 unless [0, 1, 2].include?(params[:homework_type])

    file = MultiFile.find_by_id(params[:file_id])
    return render status: 404 unless file

    case params[:homework_type]

    when 0, 2
      return render status: 403 if !file.user.id == payload['user_id'] &&
                                   User.find_by_id(payload['user_id']).user_type < 1

    when 1
      return render status: 403 if !file.team.member_ids.include?(payload['user_id']) &&
                                   User.find_by_id(payload['user_id']).user_type < 1
    end

    send_file(file.source)
  end

  def showMany
    requires(homework_id: Integer)

    payload = @@jwt_base.get_jwt_payload(request.authorization[7..])

    homework = Homework.find_by_id(params[:homework_id])

    if User.find_by_id(payload['user_id']).user_type < 1
      return render status: 403
    end

    case homework.homework_type

    when 0, 2
      homework_list = []
      SingleFile.where(homework_id: homework.id).each do |file|
        homework_list.append(file_name: file.file_name,
                             file_id: file.id)
      end

    when 1
      homework_list = []
      MultiFile.where(homework_id: homework.id).each do |file|
        homework_list.append(file_name: file.file_name,
                             file_id: file.id)
      end
    end

    return render status: 404 if homework_list.blank?

    render json: homework_list,
           status: 200
  end

  def create
    requires(:file, homework_id: Integer)
    return render status: 400 if params[:file].blank?

    params[:file].each do |file|
      return render status: 415 if File.extname(file) != '.hwp'
    end

    payload = @@jwt_base.get_jwt_payload(request.authorization[7..])
    homework = Homework.find_by_id(params[:homework_id])
    user = User.find_by_id(payload['user_id'])
    class_num = User.find_by_id(payload['user_id']).user_number / 100 - 10

    files = []
    params[:file].each do |doc|
      files.append(File.open(doc))
    end

    return render status: 404 unless homework

    case homework.homework_type

    when 0, 2

      FileUtils.mkdir_p("#{ENV['SINGLE_FILE_PATH']}/#{homework.id}")

      if homework.homework_type.zero?
        path = "#{ENV['SINGLE_FILE_PATH']}/#{homework.id}/[개인][#{homework.homework_title}] #{user.user_number}_#{user.user_name}.hwp"
        file_name = "[개인][#{homework.homework_title}] #{user.user_number}_#{user.user_name}.hwp"
      else
        path = "#{ENV['SINGLE_FILE_PATH']}/#{homework.id}/[실험][#{homework.homework_title}] #{user.user_number}_#{user.user_name}.hwp"
        file_name = "[실험][#{homework.homework_title}] #{user.user_number}_#{user.user_name}.hwp"
      end

      submit_file = homework.single_files.find_by_user_id(user.id)

      if submit_file
        homework.single_files.each do |file|
          File.delete(file.source)
        end

        files.each do |file|
          submit_file.source = upload_file(file, path)
        end

      else
        homework.single_files.each do |file|
          created_file = file.create(user_id: payload['user_id'],
                                     source: upload_file(file, path),
                                     file_name: file_name)

          late?(class_num, created_file, homework)
        end
      end

    when 1

      FileUtils.mkdir_p("#{ENV['MULTI_FILE_PATH']}/#{homework.id}")

      team = Team.find_by_leader_id_and_homework_id(payload['user_id'], homework.id)
      path = "ENV['SINGLE_FILE_PATH']/#{homework.id}/[팀][#{homework.homework_title}] #{class_num}_#{team.team_name}.hwp"
      file_name = "[팀][#{homework.homework_title}] #{class_num}_#{team.team_name}.hwp"

      team_id = homework.teams.each do |team|
        return team.id if team.member_ids.include?(user.id)
      end

      submit_file = homework.multi_files.find_by_team_id(team_id)

      if submit_file
        homework.single_files.each do |file|
          File.delete(file.source)
        end

        params[:file].each do |file|
          submit_file.source = upload_file(file, path)
        end

        file = submit_file
      else

        params[:file].each do |file|
          created_file = file.create(user_id: payload['user_id'],
                                     source: upload_file(file, path),
                                     file_name: file_name)

          late?(class_num, created_file, homework)
        end
      end
    end

    late?(class_num, file, homework)

    MailMailer.submission(user.user_email,
                          homework.homework_title,
                          file.late).deliver_later

    render status: 201
  end

  def createExcel
    requires(homework_id: Integer)

    payload = @@jwt_base.get_jwt_payload(request.authorization[7..])

    if User.find_by_id(payload['user_id']).user_type < 1
      return render status: 403
    end

    homework = Homework.find_by_id(params[:homework_id])

    return render status: 409 if homework.excel_file

    book = Spreadsheet::Workbook.new
    format_default = Spreadsheet::Format.new(horizontal_align: :center)
    format_unsubmit = Spreadsheet::Format.new(horizontal_align: :center, pattern_fg_color: :yellow)

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
      class_number = user.user_number % 100 - 10
      team_id = homework.teams.each do |team|
        return team.id if team.member_ids.include?(user.id)
      end
      user_team = Team.find_by_id(team_id)
      self_evaluation = user.self_evaluations.find_by_homework_id(params[:homework_id])

      communication = ''
      cooperation = ''

      MutualEvaluation.where(target_id: user.id, homework_id: params[:homework_id]).each do |evaluation|
        communication += "#{evaluation.communication}/#{user_team.members.count * 3}"
        cooperation += "#{evaluation.cooperation}/#{user_team.members.count * 3}"
      end

      if user_team.multi_file
        sheets[class_number - 1].row(row).push(user_team.name,
                                               user.user_number,
                                               user.user_name,
                                               homework.created_at,
                                               user_team.multi_file.late,
                                               self_evaluation.scientific_accuracy,
                                               self_evaluation.communication,
                                               self_evaluation.attitude,
                                               communication,
                                               cooperation)
      else
        sheets[class_number - 1].default_format = format_unsubmit
        sheets[class_number - 1].row(row).push(user_team.name,
                                               user.user_number,
                                               user.user_name)
      end
    end

    path = "#{ENV['EXCEL_FILE_PATH']}/[자기/상호평가]#{homework.homework_title}.xls"

    book.write(path)
    homework.excel_file.create!(source: path,
                                file_name: "[자기/상호평가]#{homework.homework_title}.xls")

    render status: 201

  end

  def showExcel
    requires(homework_id: Integer)

    file = Homework.find_by_id(params[:homework_id]).excel_file

    if file
      send_file(file.source)
    else
      render status: 404
    end
  end

  private

  def late?(class_num, file, homework)
    case class_num

    when 1
      file.late = true if homework.homework_1_deadline < Time.now
    when 2
      file.late = true if homework.homework_2_deadline < Time.now
    when 3
      file.late = true if homework.homework_3_deadline < Time.now
    when 4
      file.late = true if homework.homework_4_deadline < Time.now
    end

    file.created_at = Time.now
    file.save
  end

end
