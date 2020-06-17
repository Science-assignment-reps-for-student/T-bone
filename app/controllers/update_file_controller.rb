class UpdateFileController < ApplicationController
  before_action :jwt_required

  def update_single
    requires(:file, :homework_id)
    return render status: 400 if params[:file].blank?

    files = {}

    params[:file].each do |file|
      files[file.original_filename] = File.open(file)
      unless EXTNAME_WHITE_LIST.include?(File.extname(file))
        return render status: 415
      end
    end

    payload = @@jwt_base.get_jwt_payload(request.authorization[7..])
    user = User.find_by_id(payload['user_id'])
    homework = Homework.find_by_id(params[:homework_id])

    return render status: 412 unless user.single_files.find_by_homework_id(homework.id)

    homework.single_files.where(user_id: user.id).each do |file|
      FileUtils.rm_rf(file.source)
      file.destroy
    end

    status = SingleFile.create_single_file(user.id,
                                           homework.id,
                                           files,
                                           true)
    return render status: status if status

    MailMailer.submission(user.user_email,
                          homework.homework_title,
                          homework.homework_type,
                          homework.single_files.last.late).deliver_later
    render status: 200
  end

  def update_multi
    requires(:file, :homework_id)
    return render status: 400 if params[:file].blank?

    files = {}

    params[:file].each do |file|
      files[file.original_filename] = File.open(file)
      unless EXTNAME_WHITE_LIST.include?(File.extname(file))
        return render status: 415
      end
    end

    payload = @@jwt_base.get_jwt_payload(request.authorization[7..])
    user = User.find_by_id(payload['user_id'])
    homework = Homework.find_by_id(params[:homework_id])
    team = homework.teams.find_by_leader_id(user.id)

    return render status: 403 unless team
    return render status: 412 unless team.multi_files


    homework.multi_files.where(team_id: team.id).each do |file|
      FileUtils.rm_rf(file.source)
      file.destroy
    end

    MultiFile.create_multi_file(user.id,
                                homework.id,
                                files,
                                true)

    MailMailer.submission(user.user_email,
                          homework.homework_title,
                          homework.homework_type,
                          homework.multi_files.last.late).deliver_later
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

    if homework.excel_file
      FileUtils.rm_rf(homework.excel_file.source)
      homework.excel_file.destroy
    end

    ExcelFile.create_excel(homework.id)
    render status: 200
  end
end
