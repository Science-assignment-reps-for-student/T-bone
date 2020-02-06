class ApiController < ApplicationController
  before_action :jwt_required, except: %i[create create_user auth fun]

  def show
    requires(:homework_id)
    homework = Homework.find_by_id(params[:homework_id])
    return render status: 404 unless homework

    file_infos = []

    homework.notice_files.each do |file|
      file_infos.append(file.file_name => file.id)
    end


    render json: { homework_title: homework.homework_title,
                   homework_description: homework.homework_description,
                   homework_type: homework.homework_type,
                   homework_1_deadline: homework.homework_1_deadline,
                   homework_2_deadline: homework.homework_2_deadline,
                   homework_3_deadline: homework.homework_3_deadline,
                   homework_4_deadline: homework.homework_4_deadline,
                   created_at: homework.created_at,
                   file_info: file_infos },
           status: 200
  end

  def show_notice_file
    requires(:file_id)
    file = NoticeFile.find_by_id(params[:file_id])
    return render status: 404 unless file

    send_file(file.source)
  end

  def create
    requires(:homework_title,
             :homework_description,
             :homework_type,
             :homework_1_deadline,
             :homework_2_deadline,
             :homework_3_deadline,
             :homework_4_deadline)

    unless [0, 1, 2].include?(params[:homework_type].to_i)
      return render status: 400
    end

    payload = @@jwt_base.get_jwt_payload(request.authorization[7..])
    if User.find_by_id(payload['user_id']).user_type < 1
      return render status: 403
    end

    homework = Homework.create!(homework_title: params[:homework_title],
                                homework_description: params[:homework_description],
                                homework_type: params[:homework_type].to_i,
                                homework_1_deadline: Time.at(params[:homework_1_deadline].to_i),
                                homework_2_deadline: Time.at(params[:homework_1_deadline].to_i),
                                homework_3_deadline: Time.at(params[:homework_1_deadline].to_i),
                                homework_4_deadline: Time.at(params[:homework_1_deadline].to_i),
                                created_at: Time.now)

    params[:file]&.each do |file|
      FileUtils.mkdir_p("#{ENV['NOTICE_FILE_PATH']}/#{homework.id}")
      homework.notice_files.create!(file_name: file.original_filename,
                                    source: upload_file(File.open(file),
                                                        "#{ENV['NOTICE_FILE_PATH']}/#{homework.id}/#{file.original_filename}"))
    end

    render status: 201

  end

  def update
    requires(:homework_title,
             :homework_description,
             :homework_type,
             :homework_1_deadline,
             :homework_2_deadline,
             :homework_3_deadline,
             :homework_4_deadline,
             :homework_id)

    homework = Homework.find_by_id(params[:homework_id])
    return render status: 404 unless homework

    homework.homework_title = params[:homework_title]
    homework.homework_description = params[:homework_description]
    homework.homework_type = params[:homework_type]
    homework.homework_1_deadline = params[:homework_1_deadline]
    homework.homework_2_deadline = params[:homework_2_deadline]
    homework.homework_3_deadline = params[:homework_3_deadline]
    homework.homework_4_deadline = params[:homework_4_deadline]

    if params[:file]
      FileUtils.rm_rf("#{ENV['NOTICE_FILE_PATH']}/#{homework.id}")
    end

    params[:file]&.each do |file|
      FileUtils.mkdir_p("#{ENV['NOTICE_FILE_PATH']}/#{homework.id}")
      homework.notice_files.create!(file_name: file.original_filename,
                                    source: upload_file(File.open(file),
                                                        "#{ENV['NOTICE_FILE_PATH']}/#{homework.id}/#{file.original_filename}"))
    end

    render status: 200
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

  def fun
    render json: params
  end
end