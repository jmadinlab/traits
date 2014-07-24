class UploadApprovalMailer < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.upload_approval_mailer.approve.subject
  #
  def approve(users)
    #@greeting = "Hi #{user.name}"
    puts users
    cc_users = (users.length > 1 ) ?  users[0..-1] : [""]
    mail(to: users[0], cc: cc_users, subject: "Upload Approval")
  end
end
