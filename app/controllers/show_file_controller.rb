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
    return render status 403 if user.user_type < 1

    file = Homework.find_by_id(params[:homework_id]).excel_file

    if file
      send_file(file.source)
    else
      render status: 404
    end
  end
end
