class UploadApprovalMailer < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.upload_approval_mailer.approve.subject
  #
  def approve(user)
    @greeting = "Hi. Database Upload."

    mail to: user.email, subject: "Upload Approval"
  end
end
