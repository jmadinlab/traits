class SignUpMailer < MandrillMailer::TemplateMailer
  default from: 'suren.coral@gmail.com'

  def acknowledge(user)
    mandrill_mail template: 'signup_template',
    subject: 'Thank you for registering with Coraltraits',
    to: user.email,
    vars: {
      'username' => user.name
      },
    important: true,
    inline_css: true

  end
end