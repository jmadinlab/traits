class ObservationImportsController < ApplicationController
  before_action :contributor
  before_action :signed_in_user

  def new
    @observation_import = ObservationImport.new
  end

  def create
    @observation_import = ObservationImport.new(params[:observation_import])

    if @observation_import.save
      # Save the actual file in the server
      import_file = params[:observation_import][:file]
      save_import_file(import_file)

      redirect_to new_observation_import_path, flash: {success: "Imported observations successfully." }
    else
      render :new
    end
  end

  def approve
    # if not current_user.admin?
    #   @observations = Observation.where(:approval_status => "pending", :user_id => current_user.id)
    # else
      # @observations = Observation.where(:approval_status => "pending")
    # end

    @observations = Observation.where(:approval_status => "pending", :id => Measurement.joins(:trait).where("traits.user_id = ?", current_user.id).map(&:observation_id))

    # @observations = Observation.where(:approval_status => 'pending').joins(measurements: :trait).where("trait.user_id = ?", current_user.id)

    @pending = true

    if params[:item_id]
      reject = params[:reject]
      reject ? message = "Observation successfully rejected" : message = "Observation successfully approved"
      
      observation = @observations.find_by_id(params[:item_id])
      if not reject
        observation.approval_status = "approved"
        observation.save!
      else
        observation.destroy!
      end
      redirect_to observation_imports_approve_path, flash: {success: message } 
    else
      render :approve
    end
  end

  private

    def observation_import_params
      params.require(:observation_import).permit(:file)
    end

    def save_import_file(import_file)
      puts "Imported file saved: #{import_file.original_filename}".red
      
      file_name, extension = import_file.original_filename.split(".")
      file_name = [Time.now.strftime('%Y%m%d_%H%M%S'), file_name, current_user.id, params[:observation_import][:import_type]].join('_')
      file_with_extension = [file_name, extension].join('.')
      File.open(Rails.root.join('public', 'uploads', file_with_extension), 'wb') do |file|
        file.write(import_file.read)
      end
    end


end