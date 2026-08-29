module Admin
  module SortHelper
    def sort_link(label, column, default_desc: false, page_default: false)
      col = column.to_s
      no_sort_param = params[:sort].blank?
      active = sort_column == col || (no_sort_param && page_default)
      current_desc = no_sort_param && page_default ? default_desc : sort_desc?

      if active
        next_desc = !current_desc
      else
        next_desc = default_desc
      end

      next_sort_value = next_desc ? "-#{col}" : col
      is_default = page_default && next_desc == default_desc

      url_params = if is_default
                     request.params.except("sort")
                   else
                     request.params.merge(sort: next_sort_value)
                   end

      indicator = if active
                    current_desc ? " ▼" : " ▲"
                  else
                    " ⇅"
                  end

      css = active ? "text-accent" : "text-gray-400"

      link_to url_params, class: "inline-flex items-center gap-1 hover:text-accent transition" do
        (label + content_tag(:span, indicator, class: "text-xs #{css}")).html_safe
      end
    end
  end
end
