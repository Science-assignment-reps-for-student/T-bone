class UpdateFileController < ApplicationController
  before_action :jwt_required

  def update_single
    requires(:file, :homework_id)
    return render status: 400 if params[:file].blank?

    files = {}

    params[:file].each do |file|
      files[file.original_filename] = File.open(file)
      return render status: 415 if File.extname(file) != '.hwp'
    end

    payload = @@jwt_base.get_jwt_payload(request.authorization[7..])
    user = User.find_by_id(payload['user_id'])
    homework = Homework.find_by_id(params[:homework_id])

    return render status: 412 if homework.single_files.blank?

    FileUtils.rm_rf("#{ENV['SINGLE_FILE_PATH']}/#{homework.id}")
    user.single_files.destroy_all

    status = SingleFile.create_single_file(user.id,
                                           homework.id,
                                           files,
                                           true)
    return render status: status if status

    MailMailer.submission(user.user_email,
                          homework.homework_title,
                          homework.homework_type,
                          SingleFile.last.late).deliver_later
    render status: 200
  end

  def update_multi
    requires(:file, :homework_id)
    return render status: 400 if params[:file].blank?

    files = {}

    params[:file].each do |file|
      files[file.original_filename] = File.open(file)
      return render status: 415 if File.extname(file) != '.hwp'
    end

    payload = @@jwt_base.get_jwt_payload(request.authorization[7..])
    user = User.find_by_id(payload['user_id'])
    homework = Homework.find_by_id(params[:homework_id])
    team = homework.teams.find_by_leader_id(user.id)

    return render status: 403 unless team
    return render status: 412 if homework.multi_files.blank?


    FileUtils.rm_rf("#{ENV['MULTI_FILE_PATH']}/#{homework.id}")
    team.multi_files.destroy_all

    MultiFile.create_multi_file(user.id,
                                homework.id,
                                files,
                                true)

    MailMailer.submission(user.user_email,
                          homework.homework_title,
                          homework.homework_type,
                          MultiFile.last.late).deliver_later
    render status: 200
  end

  def update_excel
    requires(:homework_id)

    payload = @@jwt_base.get_jwt_payload(request.authorization[7..])

    if User.find_by_id(payload['user_id']).user_type < 1
      return render status: 403
    end

    homework = Homework.find_by_id(params[:homework_id])
    return render status: 404 unless homework
    return render status: 412 unless homework.excel_file

    FileUtils.rm_rf(homework.excel_file.source)
    homework.excel_file.destroy

    ExcelFile.create_excel(homework.id)
  end
end
