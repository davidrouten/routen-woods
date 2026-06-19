module Admin
  class TestimonialsController < BaseController
    before_action -> { require_permission!(:view, :testimonials) }, only: [:index]
    before_action -> { require_permission!(:manage, :testimonials) }, except: [:index]
    before_action :set_testimonial, only: [:edit, :update, :destroy]

    def index
      @testimonials = Testimonial.positioned
    end

    def new
      @testimonial = Testimonial.new
    end

    def create
      @testimonial = Testimonial.new(testimonial_params)
      if @testimonial.save
        redirect_to admin_testimonials_path, notice: "Testimonial created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @testimonial.update(testimonial_params)
        redirect_to admin_testimonials_path, notice: "Testimonial updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @testimonial.destroy
      redirect_to admin_testimonials_path, notice: "Testimonial deleted."
    end

    private

    def set_testimonial
      @testimonial = Testimonial.find(params[:id])
    end

    def testimonial_params
      params.require(:testimonial).permit(:author_name, :author_title, :body, :rating, :featured, :position)
    end
  end
end
