class CreateFileController < ApplicationController
  before_action :jwt_required

  def create_single
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

    status = SingleFile.create_single_file(user.id,
                                           homework.id,
                                           files,
                                           false)
    return render status: status if status

    MailMailer.submission(user.user_email,
                          homework.homework_title,
                          homework.homework_type,
                          homework.single_files.last.late).deliver_later
    render status: 201
  end

  def create_multi
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

    status = MultiFile.create_multi_file(user.id,
                                         homework.id,
                                         files,
                                         false)
    return render status: status if status

    MailMailer.submission(user.user_email,
                          homework.homework_title,
                          homework.homework_type,
                          homework.multi_files.last.late).deliver_later
    render status: 201
  end

  def create_excel
    requires(:homework_id)

    payload = @@jwt_base.get_jwt_payload(request.authorization[7..])

    if User.find_by_id(payload['user_id']).user_type < 1
      return render status: 403
    end

    if Homework.find_by_id(params[:homework_id]).excel_file
      return render status: 409
    end

    ExcelFile.create_excel(params[:homework_id])

    render status: 201
  end
end
