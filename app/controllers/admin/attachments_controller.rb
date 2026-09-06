module Admin
  class AttachmentsController < BaseController
    before_action :set_project
    before_action :set_attachment, only: [:show, :edit, :update, :destroy]
    before_action -> { require_permission!(:manage, :leads) }

    def show
    end

    def edit
    end

    def update
      new_project_id = attachment_params[:project_id]

      if @attachment.update(attachment_params)
        target_project = @attachment.project
        redirect_to admin_project_attachment_path(target_project, @attachment), notice: "Attachment updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def create
      files = Array(params[:files])

      if files.empty?
        redirect_to admin_project_path(@project), alert: "No files selected."
        return
      end

      files.each do |file|
        @project.attachments.create!(
          file: file,
          description: params[:description].presence,
          uploaded_by: current_user
        )
      end

      redirect_to admin_project_path(@project), notice: "#{files.size} #{'file'.pluralize(files.size)} uploaded."
    end

    def destroy
      @attachment.destroy
      redirect_to admin_project_path(@project), notice: "Attachment deleted."
    end

    private

    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_attachment
      @attachment = @project.attachments.find(params[:id])
    end

    def attachment_params
      params.require(:attachment).permit(:description, :project_id)
    end
  end
end
