class ShowFileController < ApplicationController
  before_action :jwt_required

  def show_single
    requires(:file_id)

    payload = @@jwt_base.get_jwt_payload(request.authorization[7..])
    file = SingleFile.find_by_id(params[:file_id])
    return render status: 404 unless file
    return render status: 403 if file.user.id != payload['user_id'] &&
                                 User.find_by_id(payload['user_id']).user_type < 1

    send_file(file.source)
  end


  def show_multi
    requires(:file_id)

    payload = @@jwt_base.get_jwt_payload(request.authorization[7..])
    file = SingleFile.find_by_id(params[:file_id])
    return render status: 404 unless file
    return render status: 403 if !file.team.member_ids.include?(payload['user_id']) &&
                                 User.find_by_id(payload['user_id']).user_type < 1

    send_file(file.source)
  end

  def show_excel
    requires(:homework_id)

    payload = @@jwt_base.get_jwt_payload(request.authorization[7..])
    user = User.find_by_id(payload['user_id'])
    return render status: 403 if user.user_type < 1

    file = Homework.find_by_id(params[:homework_id]).excel_file

    if file
      send_file(file.source)
    else
      render status: 404
    end
  end

  def show_notice
    requires(:file_id)
    file = NoticeFile.find_by_id(params[:file_id])
    return render status: 404 unless file

    send_file(file.source)
  end

  def show_many
    requires(:homework_id)

    payload = @@jwt_base.get_jwt_payload(request.authorization[7..])
    user = User.find_by_id(payload['user_id'])
    homework = Homework.find_by_id(params[:homework_id])

    return render status: 403 if user.user_type < 1
    return render status: 404 unless homework

    if homework.homework_type.zero?
      homework_type = '개인'
      path = ENV['SINGLE_FILE_PATH']

    elsif homework.homework_type == 1
      homework_type = '팀'
      path = ENV['MULTI_FILE_PATH']

    else
      homework_type = '실험'
      path = ENV['SINGLE_FILE_PATH']

    end

    FileUtils.rm_rf("[#{homework_type}]#{homework.homework_title}.zip")
    system("zip -r #{path}/'[#{homework_type}]#{homework.homework_title}'.zip #{homework.id}")
    send_file("#{path}/[#{homework_type}]#{homework.homework_title}.zip")
    render json: { file_name: "[#{homework_type}]#{homework.homework_title}.zip" }
  end
end
