class ApplicationController < ActionController::API
  EXTNAME_WHITE_LIST = %w[.hwp .jpg .png .jpeg .pptx .word .pdf].freeze

  require 'jwt_base'
  @@jwt_base = JWTBase::JWTBase.new(ENV['SECRET_KEY_BASE'], 1.days, 2.weeks)

  def jwt_required
    begin
      token = request.authorization[7..]
    rescue NoMethodError
      return render status: 401
    end

    @payload = @@jwt_base.get_jwt_payload(token)

    return render status: 401 unless @payload
    return render status: @payload['err'] if @payload['err']
    return render status: 403 unless @payload['type'] == 'access_token'
  end

  def refresh_token_required
    begin
      token = request.authorization[7..]
    rescue NoMethodError
      return render status: 401
    end

    @payload = @@jwt_base.get_jwt_payload(token)

    return render status: 401 unless @payload
    return render status: @payload['err'] if @payload['err']
    return render status: 403 unless @payload['type'] == 'refresh_token'
  end

  def upload_file(file, path)
    File.rename(file, path)

    path
  end

  def requires(*args, **kwargs)
    unless args.blank?
      args.each do |arg|
        params.require(arg.to_sym)
      end
    end

    unless kwargs.blank?
      kwargs.each do |key, value|
        unless value.class == Class
          raise TypeError
        end

        params.require(key.to_sym)
        unless params[key.to_sym].class == value
          return render status: 400
        end
      end
    end

    params
  end

  def self.late?(class_num, file, homework)
    case class_num

    when 1
      file.late = homework.homework_1_deadline < Time.now
    when 2
      file.late = homework.homework_2_deadline < Time.now
    when 3
      file.late = homework.homework_3_deadline < Time.now
    when 4
      file.late = homework.homework_4_deadline < Time.now
    end

    file.created_at = Time.now
    file.save
  end

  def self.upload_file(file, path)
    FileUtils.mv(file, path)

    path
  end

  def current_user
    User.find_by_id(@payload['user_id'])
  end
end
