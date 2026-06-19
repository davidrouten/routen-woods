module Admin
  class NotesController < BaseController
    before_action -> { require_permission!(:create, :notes) }, only: [:create]
    before_action -> { require_permission!(:delete, :notes) }, only: [:destroy]

    def create
      @lead = Lead.find(params[:lead_id])
      @note = SalesEngine.add_note(@lead, params[:note][:body], user: current_user)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_lead_path(@lead) }
      end
    end

    def destroy
      @note = Note.find(params[:id])
      unless current_user.admin? || @note.user == current_user
        redirect_to admin_lead_path(@note.lead), alert: "Not authorized"
        return
      end
      @note.destroy
      redirect_to admin_lead_path(@note.lead), notice: "Note removed."
    end
  end
end
