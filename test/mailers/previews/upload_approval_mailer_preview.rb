# Preview all emails at http://localhost:3000/rails/mailers/upload_approval_mailer
class UploadApprovalMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/upload_approval_mailer/approve
  def approve
    UploadApprovalMailer.approve
  end

end
