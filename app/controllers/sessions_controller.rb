class SessionsController < ApplicationController
  def login_form
  end

  def create
    auth_hash = request.env['omniauth.auth']

    if auth_hash['uid']
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      if @user.nil?
        # User doesn't match anything in the DB
        # Attempt to create a new user
        # @user = User.new(
        #   username: auth_hash['info']['name'],
        #   email: auth_hash['info']['email'],
        #   uid: auth_hash['uid'],
        #   provider: auth_hash['provider'])
        user = User.build_from_github(auth_hash)
        if @user.save
        session[:user_id] = @user.id
        flash[:success] = "Logged in successfully"
        redirect_to root_path
        else
        flash[:error] = "Could not log in"
        redirect_to root_path
        end
      else
      session[:user_id] = @user.id
      flash[:error] = "Could not log in"
      redirect_to root_path
      end
    end
  end

  def index
    @user = User.find(session[:user_id]) # < recalls the value set in a previous request
  end


  # def destroy
  #   session[:user_id] = nil
  #   flash[:success] = "Successfully logged out!"
  #
  #   redirect_to root_path
  # end

  def login
    username = params[:username]
    if username and user = User.find_by(username: username)
      session[:user_id] = user.id
      flash[:status] = :success
      flash[:result_text] = "Successfully logged in as existing user #{user.username}"
    else
      user = User.new(username: username)
      if user.save
        session[:user_id] = user.id
        flash[:status] = :success
        flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
      else
        flash.now[:status] = :failure
        flash.now[:result_text] = "Could not log in"
        flash.now[:messages] = user.errors.messages
        render "login_form", status: :bad_request
        return
      end
    end
    redirect_to root_path
  end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end
