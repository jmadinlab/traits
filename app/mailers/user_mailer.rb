class UserMailer < ActionMailer::Base
  default from: 'coraltraits@gmail.com'

  def password_reset(user)
    @user = user

    mail to: user.email, :subject => "Coral Trait Database: password reset"

    '''
    mandrill_mail template: "password_reset",
                  subject: "Coraltraits : Reset Password",
                  to: user.email,
                  vars: {
                          "USERNAME" => user.name,
                          "EMAIL" => user.email,
                          "EDIT_LINK" => edit_password_reset_url(user.password_reset_token)
                        }
    
    '''
                  
  end

  def password_reset_confirmation(user)
    @user = user
    mail to: user.email, :subject => "Coral Trait Database: password reset confirmation"
  
    '''
    mandrill_mail template: "password_reset_confirmation",
                  subject: "Coraltraits : Password Reset Confirmation",
                  to: user.email,
                  vars: {
                          "USERNAME" => user.name,
                        }
    '''    
  end
end
