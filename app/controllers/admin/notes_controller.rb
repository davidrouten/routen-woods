module Admin
  class NotesController < BaseController
    before_action :set_notable
    before_action -> { require_permission!(:create, :notes) }, only: [:create]
    before_action -> { require_permission!(:delete, :notes) }, only: [:destroy]

    def create
      @note = @notable.notes.create!(body: params[:body], user: current_user)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to notable_path }
      end
    end

    def destroy
      @note = Note.find(params[:id])
      unless current_user.admin? || @note.user == current_user
        redirect_to notable_path, alert: "Not authorized"
        return
      end
      @note.destroy
      redirect_to notable_path, notice: "Note removed."
    end

    private

    def set_notable
      if params[:lead_id]
        @notable = Lead.find(params[:lead_id])
      elsif params[:project_id]
        @notable = Project.find(params[:project_id])
      end
    end

    def notable_path
      case @notable
      when Lead then admin_lead_path(@notable)
      when Project then admin_project_path(@notable)
      end
    end
  end
end
