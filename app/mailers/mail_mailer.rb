class MailMailer < ApplicationMailer
  def submission(target, title, late)
    @homework_title = title
    @late = late
    mail(to: target, subject: "[제출 알림]#{title}", content_type: 'text/html')
  end
end
