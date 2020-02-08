class MailMailer < ApplicationMailer
  def submission(target, title, type, late)
    @homework_title = title
    @homework_type = type
    @late = late
    mail(from: 'notify@dsm.hs.kr', to: target, subject: "[제출 알림]#{title}", content_type: 'text/html')
  end
end
