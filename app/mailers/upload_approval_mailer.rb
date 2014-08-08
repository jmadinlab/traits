class UploadApprovalMailer < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.upload_approval_mailer.approve.subject
  #
  def approve(user)
    @greeting = "Hi #{user.name}"
    
    mail(to: user.email,  subject: "Coral Trait Database change approval")
  end

  def approve_all(users)
    #@greeting = "Hi #{user.name}"
    puts users
    cc_users = (users.length > 1 ) ?  users[0..-1] : [""]
    mail(to: users[0], cc: cc_users, subject: "Coral Trait Database change approval")
  end
end
