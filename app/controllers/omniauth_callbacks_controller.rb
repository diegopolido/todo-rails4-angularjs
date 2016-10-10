class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    email_with_another_provider = User.where(email: request.env["omniauth.auth"].info.email).where.not(provider: :facebook).first
    if email_with_another_provider
      flash[:notice] = I18n.t "devise.omniauth_callbacks.failure", :kind => "Facebook", :reason => "E-mail already used by another provider."
      redirect_to new_user_registration_url
    else
      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      else
        session["devise.facebook_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end
  end

  def google_oauth2
    email_with_another_provider = User.where(email: request.env["omniauth.auth"].info.email).where.not(provider: :google_oauth2).first
    if email_with_another_provider
      flash[:notice] = I18n.t "devise.omniauth_callbacks.failure", :kind => "Google", :reason => "E-mail already used by another provider."
      redirect_to new_user_registration_url
    else
      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
        sign_in_and_redirect @user, :event => :authentication
      else
        session["devise.google_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end
  end

  def failure
    redirect_to root_path
  end
end