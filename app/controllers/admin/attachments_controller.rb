module Admin
  class AttachmentsController < BaseController
    before_action :set_attachable
    before_action :set_attachment, only: [:show, :edit, :update, :destroy]
    before_action -> { require_permission!(:manage, :leads) }

    ATTACHABLE_TYPES = %w[Project Invoice OrderForm].freeze

    def show
    end

    def edit
    end

    def update
      assign_attachable_from_gid
      if @attachment.update(attachment_params)
        redirect_to polymorphic_path([:admin, @attachment.attachable, @attachment]), notice: "Attachment updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def create
      files = Array(params[:files])

      if files.empty?
        redirect_to polymorphic_path([:admin, @attachable]), alert: "No files selected."
        return
      end

      files.each do |file|
        @attachable.attachments.create!(
          file: file,
          description: params[:description].presence,
          uploaded_by: current_user
        )
      end

      redirect_to polymorphic_path([:admin, @attachable]), notice: "#{files.size} #{'file'.pluralize(files.size)} uploaded."
    end

    def destroy
      @attachment.destroy
      redirect_to polymorphic_path([:admin, @attachable]), notice: "Attachment deleted."
    end

    private

    def set_attachable
      if params[:invoice_id].present?
        @attachable = Invoice.find(params[:invoice_id])
      elsif params[:order_form_id].present?
        @attachable = OrderForm.find(params[:order_form_id])
      elsif params[:project_id].present?
        @attachable = Project.find(params[:project_id])
      end
    end

    def set_attachment
      @attachment = @attachable.attachments.find(params[:id])
    end

    def assign_attachable_from_gid
      gid = params.dig(:attachment, :attachable_gid)
      return unless gid.present?

      type, id = gid.split("-", 2)
      return unless ATTACHABLE_TYPES.include?(type) && id.present?

      @attachment.attachable = type.constantize.find(id)
    end

    def attachment_params
      params.require(:attachment).permit(:description)
    end
  end
end
