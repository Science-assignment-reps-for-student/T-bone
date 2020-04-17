class ApiController < ApplicationController
  before_action :jwt_required, except: %i[create_user auth email]

  def email
    requires(:auth_code, :target)

    MailMailer.auth(params[:target], params[:auth_code]).deliver_later
  end

  def show
    requires(:homework_id)
    homework = Homework.find_by_id(params[:homework_id])
    return render status: 404 unless homework

    file_infos = []

    homework.notice_files.each do |file|
      file_infos.append(file_name: file.file_name,
                        file_id: file.id)
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

    unless params[:file].blank?
      params[:file].each do |file|
        FileUtils.mkdir_p("#{ENV['NOTICE_FILE_PATH']}/#{homework.id}")
        homework.notice_files.create!(file_name: file.original_filename,
                                      source: ApplicationController.upload_file(File.open(file),
                                                          "#{ENV['NOTICE_FILE_PATH']}/#{homework.id}/#{file.original_filename}"))
      end
    end

    unless homework.homework_type.zero?
      exp = Time.at([params[:homework_1_deadline].to_i,
                     params[:homework_2_deadline].to_i,
                     params[:homework_3_deadline].to_i,
                     params[:homework_4_deadline].to_i].max)

      MakeExcelJob.set(wait_until: exp).perform_later(homework.id)
    end

    render status: 201
  end

  def destroy
    requires(:homework_id)

    homework = Homework.find_by_id(params[:homework_id])

    FileUtils.rm_rf("#{ENV['NOTICE_FILE_PATH']}/#{homework.id}")

    homework.destroy!
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
    homework.homework_1_deadline = Time.at(params[:homework_1_deadline].to_i)
    homework.homework_2_deadline = Time.at(params[:homework_2_deadline].to_i)
    homework.homework_3_deadline = Time.at(params[:homework_3_deadline].to_i)
    homework.homework_4_deadline = Time.at(params[:homework_4_deadline].to_i)

    unless params[:file].blank?
      homework.notice_files.destroy_all

      FileUtils.rm_rf("#{ENV['NOTICE_FILE_PATH']}/#{params[:homework_id]}")

      params[:file].each do |file|
        FileUtils.mkdir_p("#{ENV['NOTICE_FILE_PATH']}/#{params[:homework_id]}")
        NoticeFile.create!(file_name: file.original_filename,
                           homework_id: params[:homework_id],
                           source: ApplicationController.upload_file(File.open(file),
                                               "#{ENV['NOTICE_FILE_PATH']}/#{params[:homework_id]}/#{file.original_filename}"))
      end

    end

    homework.save

    render status: 200
  end

  def show_files
    requires(:homework_id)

    homework = Homework.find_by_id(params[:homework_id])

    return render status: 404 unless homework

    file_info = []
    response = {}

    if homework.homework_type == 1

      homework.multi_files.each do |file|
        file_info.append(file_name: file.file_name,
                         file_id: file.id,
                         team_id: file.team.id,
                         team_name: file.team.team_name)
      end
      if homework.excel_file
        response[:file_excel_name] = homework.excel_file.file_name
      end
    elsif homework.homework_type == 2

      homework.single_files.each do |file|
        file_info.append(file_name: file.file_name,
                         file_id: file.id,
                         user_id: file.user.id,
                         user_number: file.user.user_number)
      end
      if homework.excel_file
        response[:file_excel_name] = homework.excel_file.file_name
      end
    else

      homework.single_files.each do |file|
        file_info.append(file_name: file.file_name,
                         file_id: file.id,
                         user_id: file.user.id,
                         user_number: file.user.user_number)
      end
    end

    case homework.homework_type

    when 0
      homework_type = '개인'
    when 1
      homework_type = '팀'
    when 2
      homework_type = '실험'

    end

    response[:file_info] = file_info
    response[:file_zip_info] = "[#{homework_type}]#{homework.homework_title}.zip"

    render json: response, status: 200
  end
end