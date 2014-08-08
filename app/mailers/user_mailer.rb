class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @greeting = "Hi"
    @user = user

    mail to: user.email, :subject => "Coral Trait Database: password reset"

    '''
    mandrill_mail template: "password-reset",
                  subject: "Coraltraits : Reset Password",
                  to: user.email,
                  vars: {
                          "EMAIL" => user.email,
                          "EDIT_LINK" => edit_password_reset_url(user.password_reset_token)
                        }
    '''
                  
  end

  def password_reset_confirmation(user)
    @greeting = "Hi"
    @user = user

    mail to: user.email, :subject => "Coral Trait Database: password reset confirmation"
  end
end
