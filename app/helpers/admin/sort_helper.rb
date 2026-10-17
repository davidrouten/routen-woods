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

      # Built from the current path and query string only, so a crafted
      # param (e.g. host=) can't point the link somewhere else.
      query = request.query_parameters.except("sort")
      query["sort"] = next_sort unless back_to_default
      url = query.empty? ? request.path : "#{request.path}?#{query.to_query}"

      indicator = if active
                    active_desc ? " ▼" : " ▲"
                  else
                    " ⇅"
                  end

      css = active ? "text-accent" : "text-gray-400"

      link_to url, class: "inline-flex items-center gap-1 hover:text-accent transition" do
        safe_join([label, content_tag(:span, indicator, class: "text-xs #{css}")])
      end
    end
  end
end
