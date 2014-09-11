class SignUpMailer < ActionMailer::Base
  default from: 'coraltraits@gmail.com'

  def acknowledge(user)
    @user = user

    mail to: user.email, :subject => "Thank you for Signing Up with Coraltraits"
    
    """
    mandrill_mail template: 'signup_template',
    subject: 'Thank you for registering with Coraltraits',
    to: user.email,
    vars: {
      'username' => user.name
      },
    important: true,
    inline_css: true
    """
  end
end