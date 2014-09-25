class IssuesController < ApplicationController
  before_action :signed_in_user
  before_action :set_issue, only: [:edit, :update, :destroy]
  before_action :contributor, only: :index

  # GET /issues
  # GET /issues.json
  def index
    @issues = Issue.all
  end

  # GET /issues/new
  def new
    @issue = Issue.new
    @observation = Observation.find(params[:observation_id])
  end

  # GET /issues/1/edit
  def edit
  end

  # POST /issues
  # POST /issues.json
  def create
    @issue = Issue.new(issue_params)
    @observation = Observation.find(params[:observation_id])

    if @issue.save
      redirect_to observation_path(@observation)
    else
      redirect_to observation_path(@observation), flash: {danger: "Issue not created.  You need a description." }
    end
  end

  # PATCH/PUT /issues/1
  # PATCH/PUT /issues/1.json
  def update
    if @issue.update(issue_params)
      redirect_to observation_path(@issue.observation)
    else
      redirect_to edit_observation_issue_path(@issue.observation, @issue), flash: {danger: "Issue not updated.  You need a description." }
      # render :edit
    end
  end

  # DELETE /issues/1
  # DELETE /issues/1.json
  def destroy
    @observation = Observation.find(params[:observation_id])
    @issue.destroy
    redirect_to observation_path(@observation)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_issue
      @issue = Issue.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def issue_params
      params.require(:issue).permit(:user_id, :observation_id, :issue_description, :resolved, :resolved_description, :resolved_user)
    end
end
