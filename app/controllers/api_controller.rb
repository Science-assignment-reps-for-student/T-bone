class ApiController < ApplicationController
  before_action :jwt_required, except: %i[create_user auth]

  def show
    requires(:homework_id)
    homework = Homework.find_by_id(params[:homework_id])
    return render status: 404 unless homework

    homework.notice_files.each do |file|
      send_file(file.source)
    end

    render json: { homework_title: homework.homework_title,
                   homework_description: homework.homework_description,
                   homework_type: homework.homework_type,
                   homework_1_deadline: homework.homework_1_deadline,
                   homework_2_deadline: homework.homework_2_deadline,
                   homework_3_deadline: homework.homework_3_deadline,
                   homework_4_deadline: homework.homework_4_deadline,
                   created_at: homework.created_at,
                   file_id: homework.notice_file_ids },
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

    return render status: 400 unless [0, 1, 2].include?(params[:homework_type])

    homework = Homework.create!(homework_title: params[:homework_title],
                                homework_description: params[:homework_description],
                                homework_type: params[:homework_type],
                                homework_1_deadline: params[:homework_1_deadline],
                                homework_2_deadline: params[:homework_2_deadline],
                                homework_3_deadline: params[:homework_3_deadline],
                                homework_4_deadline: params[:homework_4_deadline],
                                created_at: Time.now)

    NoticeFile.create!(homework_id: homework.id,
                       source: upload_file(File.open(params[:file]),
                                     "#{ENV['NOTICE_FILE_PATH']}/#{homework.id}/[양식]#{homework.homework_title}"))

    render status: 201

  end

  def auth
    requires(:user_email, :user_pw)

    user = User.find_by_user_email(params[:user_email])
    if user
      if user.user_pw == params[:user_pw]
        render json: { access_token: @@jwt_base.create_access_token(user_id: user.id) },
               status: 200
      else
        render status: 401
      end
    else
      render status: 404
    end
  end

  def create_user
    requires(:user_email,
             :user_pw,
             :user_number,
             :user_name,
             :user_type)

    User.create!(user_email: params[:user_email],
                 user_pw: params[:user_pw],
                 user_number: params[:user_number],
                 user_name: params[:user_name],
                 user_type: params[:user_type])

    render status: 201
  end
end