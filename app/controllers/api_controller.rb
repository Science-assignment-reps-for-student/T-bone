class ApiController < ApplicationController
   before_action :jwt_required

  def show
    requires(:homework_id)
    homework = Homework.find_by_id(params[:homework_id])
    return render status: 404 unless homework

    send_file(homework.notice_file.source)
    render json: { homework_title: homework.homework_title,
                   homework_description: homework.homework_description,
                   homework_type: homework.homework_type,
                   homework_1_deadline: homework.homework_1_deadline,
                   homework_2_deadline: homework.homework_2_deadline,
                   homework_3_deadline: homework.homework_3_deadline,
                   homework_4_deadline: homework.homework_4_deadline,
                   created_at: homework.created_at,
                   file_id: homework.notice_file.id },
           status: 200

  end

  def create
    requires(:homework_title,
             :homework_description,
             :homework_type,
             :homework_1_deadline,
             :homework_2_deadline,
             :homework_3_deadline,
             :homework_4_deadline,
             :file)

    return render status: 400 unless params[:file]
    homework = Homework.create!(homework_title: params[:homework_title],
                                homework_description: params[:homework_description],
                                homework_type: params[:homework_type],
                                homework_1_deadline: params[:homework_1_deadline],
                                homework_2_deadline: params[:homework_2_deadline],
                                homework_3_deadline: params[:homework_3_deadline],
                                homework_4_deadline: params[:homework_4_deadline],
                                created_at: Time.now.to_i)

    NoticeFile.create!(homework_id: homework.id,
                       source: upload_file(File.open(params[:file]),
                                     "#{ENV['NOTICE_FILE_PATH']}/#{homework.id}/[양식]#{homework.homework_title}"))

    return render status: 201

  end
end