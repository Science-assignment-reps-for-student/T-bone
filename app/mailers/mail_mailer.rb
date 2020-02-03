class MailMailer < ApplicationMailer
  def submission(target, title)
    @homework_title = title
    mail(to: target, subject: "[제출 알림]#{title}", content_type: 'text/html')
  end
end
