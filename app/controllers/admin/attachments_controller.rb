module Admin
  class AttachmentsController < BaseController
    before_action :set_project
    before_action -> { require_permission!(:manage, :leads) }

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
      attachment = @project.attachments.find(params[:id])
      attachment.destroy
      redirect_to admin_project_path(@project), notice: "Attachment deleted."
    end

    private

    def set_project
      @project = Project.find(params[:project_id])
    end
  end
end
