class FileController < ApplicationController
  before_action :jwt_required

  def showOne
    requires(homework_type: Integer, file_id: Integer)

    payload = @@jwt_base.get_jwt_payload(request.authorization)

    render status: 400 unless [0,1,2].include?(params[:homework_type])

    case params[:homework_type]

    when 0, 2
      file = SingleFile.find_by_id(params[:file_id])
      return render status: 403 unless file.user.id == payload['user_id']

    when 1
      file = MultiFile.find_by_id(params[:file_id])
      return render status: 403 if !file.team.members.ids.include?(payload['user_id']) &&
          User.find_by_id(payload['user_id']).user_type < 1
    end

    return render status: 404 unless file

    send_file(file.source)
    render status: 200
  end

  def showMany
    requires(homework_id: Integer)

    payload = @@jwt_base.get_jwt_payload(request.authorization)

    homework = Homework.find_by_id(params[:homework_id])

    case homework.homework_type

    when 0, 2
      homework_list = SingleFile.where(homework_id: params[:homework_id]).ids

    when 1
      homework_list = MultiFile.where(homework_id: params[:homework_id]).ids

    end

    return render status: 403 if User.find_by_id(payload['user_id']).user_type < 1
    return render status: 404 if homework_list.blank?

    render json: homework_list, status: 200
  end

  def create
    requires(:file, homework_id: Integer)
    return render status: 415 if File.extname(params[:file]) != '.hwp'

    payload = @@jwt_base.get_jwt_payload(request.authorization)
    homework = Homework.find_by_id(params[:homework_id])
    user = User.find_by_id(payload['user_id'])
    class_num = User.find_by_id(payload['user_id']).user_number / 100 - 10
    file = File.open(params[:file])

    return render status: 404 unless homework

    case homework.homework_type

    when 0, 2

      FileUtils.mkdir_p("#{ENV['SINGLE_FILE_PATH']}/#{homework.id}")

      if homework.homework_type == 0
        path = "#{ENV['SINGLE_FILE_PATH']}/#{homework.id}/[개인][#{homework.homework_title}] #{user.user_number}_#{user.user_name}.hwp"
      else
        path = "#{ENV['SINGLE_FILE_PATH']}/#{homework.id}/[실험][#{homework.homework_title}] #{user.user_number}_#{user.user_name}.hwp"
      end

      if homework.single_file.source
        File.delete(homework.single_file.source)
        homework.single_file.source = upload_file(file, path)

        temp_homework = homework
      else
        temp_homework = homework.single_file.create(user_id: payload['user_id'],
                                                    source: upload_file(file, path))
      end

    when 1

      FileUtils.mkdir_p("#{ENV['MULTI_FILE_PATH']}/#{homework.id}")

      team = Team.find_by_leader_id_and_homework_id(payload['user_id'], homework.id)
      path = "ENV['SINGLE_FILE_PATH']/#{homework.id}/[팀][#{homework.homework_title}] #{class_num}_#{team.team_name}.hwp"

      if homework.multi_file.source
        File.delete(homework.multi_file.source)
        homework.multi_file.source = upload_file(file, path)

        temp_homework = homework
      else
        temp_homework = homework.multi_file.create(user_id: payload['user_id'],
                                                    source: upload_file(file, path))
      end

    end

    late?(class_num, temp_homework)

    render status: 201
  end

  def createExcel
    requires(homework_id: Integer)

    payload = @@jwt_base.get_jwt_payload(request.authorization)

    return render status: 403 if User.find_by_id(payload['user_id']).user_type < 1


    book = Spreadsheet::Workbook.new
    format_default = Spreadsheet::Format.new(pattern_fg_color: :yellow)
    format_unsubmit = Spreadsheet::Format.new(pattern_fg_color: :red)

    class_1 = book.create_worksheet(name: '1반')
    class_2 = book.create_worksheet(name: '2반')
    class_3 = book.create_worksheet(name: '3반')
    class_4 = book.create_worksheet(name: '4반')

    [class_1, class_2, class_3, class_4].each do |sheet|
      sheet.row(0).push('조', '학번', '이름', '제출 일시', '과학적 정확성', '의사소통', '흥미/태도(협력)', )
    end

  end

  def showExcel

  end

  private

  def late?(class_num, homework)
    case class_num

    when 1
      homework.late = true if homework.homework_1_deadline < Time.now.to_i
    when 2
      homework.late = true if homework.homework_2_deadline < Time.now.to_i
    when 3
      homework.late = true if homework.homework_3_deadline < Time.now.to_i
    when 4
      homework.late = true if homework.homework_4_deadline < Time.now.to_i
    end

    homework.created_at = Time.now.to_i
    homework.save
  end

end
