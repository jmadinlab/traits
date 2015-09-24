class VersionsController < ApplicationController

  before_action :editor
  
  def index
    @versions = PaperTrail::Version.order('created_at DESC').paginate(page: params[:page])
    
    @versions_by_item = params[:type] ? PaperTrail::Version.where(item_type: params[:type]).paginate(page: params[:page]) : @versions
  end

  def show
    @version = PaperTrail::Version.find_by_id(params[:version_id])
    
    if @version.event == 'create'
      @object_fields = ''
      @object = []
    else
      @object_fields = @version.object.split("\n")

      # ignoring the first item which is '---'
      @object_fields.delete('---')
      @object = []
      @object_fields.each do |obj|
        @object.append([ obj.split(":")[0], obj.split(":")[1] ])
      end
    end    
  end

  def revert_back
    #@version = PaperTrail::Version.find_by_id(params[:id])
    @version = PaperTrail::Version.find_by_id(params[:version_id])
    begin
      if @version.reify
        # revert back to any action (update, destroy )
        @version.reify.save
      else
        # revert back for create action
        @version.item.destroy
      end
      flash[:success] = 'Successfully reverted back to previous version'

    rescue
      flash[:alert] = 'Revert failed'
    ensure 
      redirect_to history_path
    end

  end

  # Create revert back link for version history
  #def make_revert_link(specie_id)
  #  @item = Specie.find_by_id(specie_id)
    #view_context.link_to 'Revert Back', revert_back_path(@specie.versions.last), method: :post
  #end
end
