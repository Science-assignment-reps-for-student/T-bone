class MailMailer < ApplicationMailer
  def submission(target, title, type, late)
    @user_name = User.find_by_user_email(target).user_name
    @homework_title = title
    @homework_type = if type.zero?
                       '개인'
                     elsif type == 1
                       '팀'
                     else
                       '실험'
                     end
    @late = if late
              '지각'
            else
              '제출'
            end
    mail(from: 'notify@scarfs.hs.kr',
         to: target,
         subject: "[제출 알림][#{@homework_type}]#{title}",
         content_type: 'text/html')
  end

  def auth(target, auth_code)
    @auth_code = auth_code
    mail(from: 'notify@scarfs.hs.kr',
         to: target,
         subject: 'scarfs 회원가입 인증코드',
         content_type: 'text/html')
  end
end
