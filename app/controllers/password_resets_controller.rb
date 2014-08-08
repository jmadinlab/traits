class PasswordResetsController < ApplicationController
  
  def new
  end

  def create
	  user = User.find_by_email(params[:email])
	  if user
	  	user.send_password_reset
	  	redirect_to root_url, flash: {success: "An email has been sent with password reset instructions." }
	  else
	  	redirect_to signup_url, flash: {danger: "No such email.  Want to sign up?" }
	  end
	end

	def edit
	  begin
	  	@user = User.find_by_password_reset_token!(params[:id])
	  rescue
			redirect_to root_url, flash: { danger: "Sorry, the Password Reset link is outdated. Please request a new link." }
	  end
	end

	def update
	  @user = User.find_by_password_reset_token!(params[:id])
	  puts "user in controller: "
	  puts @user.email
	  puts params[:user]

	  if @user.password_reset_sent_at < 2.hours.ago
	    redirect_to new_password_reset_path, flash: { danger: "Reset has expired." }
	  elsif @user.update_attributes(user_params)
	    UserMailer.password_reset_confirmation(@user).deliver
	    redirect_to root_url, flash: { success: "Your password has been reset." }
	  else
	    render :edit
	  end
	end

	def user_params
    params.require(:user).permit(:password, :password_confirmation)
 	end
end
