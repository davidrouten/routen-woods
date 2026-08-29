module Admin
  module SortHelper
    def sort_link(label, column, default_desc: false, page_default: false)
      col = column.to_s
      no_sort_param = !current_sort.active?
      active = current_sort.column == col || (no_sort_param && page_default)

      active_desc = if no_sort_param && page_default
                      default_desc
                    else
                      current_sort.desc?
                    end

      next_desc = active ? !active_desc : default_desc
      next_sort = next_desc ? "-#{col}" : col
      back_to_default = page_default && next_desc == default_desc

      url_params = if back_to_default
                     request.params.except("sort")
                   else
                     request.params.merge(sort: next_sort)
                   end

      indicator = if active
                    active_desc ? " ▼" : " ▲"
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
