# Admin UI/UX Style Guide

All admin views must follow these patterns. No exceptions without updating this guide first.

---

## Buttons

| Class | Use | Look |
|---|---|---|
| `btn-admin` | Primary actions (Save, Create, New) | Gold bg, dark text |
| `btn-admin-secondary` | Secondary actions (Cancel, Back) | Gray bg |
| `btn-admin-destructive` | Destructive actions (Delete) | Red bg |
| `btn-admin-link` | Inline small links (View details, Add) | Gold text, light gold bg |

Never use inline/one-off button styles. If a new pattern is needed, add a component class to `components.css` first.

---

## Icon Button Groups

Edit/Delete actions use a **joined button group** — a single bordered container with a divider between icons. Defined in `components.css`.

| Class | Use | Look |
|---|---|---|
| `icon-btn-group` | Wrapper container | Rounded border, divider between children |
| `icon-btn` | Edit/secondary icon | Gold (accent) icon, gold tint on hover |
| `icon-btn-destructive` | Delete/destructive icon | Red icon, red tint on hover |

### Index row markup (w-4 icons):
```erb
<div class="flex justify-end">
  <div class="icon-btn-group">
    <%= link_to edit_admin_resource_path(resource), class: "icon-btn", title: "Edit" do %>
      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"/></svg>
    <% end %>
    <%= button_to admin_resource_path(resource), method: :delete, form_class: "contents", class: "icon-btn-destructive", title: "Delete", data: { turbo_confirm: "Delete this resource?" } do %>
      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
    <% end %>
  </div>
</div>
```

### Show page header markup (w-5 icons):
```erb
<div class="flex items-center gap-3">
  <span class="inline-block px-3 py-1 rounded-full text-sm font-medium ...">Status</span>
  <div class="icon-btn-group">
    <%= link_to edit_admin_resource_path(@resource), class: "icon-btn", title: "Edit" do %>
      <svg class="w-5 h-5" ...pencil...></svg>
    <% end %>
    <%= button_to admin_resource_path(@resource), method: :delete, form_class: "contents", class: "icon-btn-destructive", title: "Delete", data: { turbo_confirm: "Delete?" } do %>
      <svg class="w-5 h-5" ...trash...></svg>
    <% end %>
  </div>
</div>
```

### Standalone icon buttons (nested form remove)

For remove buttons on nested form rows (line items, payments, adjustments), use a **standalone** `icon-btn-destructive` (not inside a group). The icon changes based on whether the row is persisted:

- **Persisted row** (will be soft-deleted): trash can icon
- **New row** (will just be removed from DOM): X icon

```erb
<button type="button" data-action="nested-form#remove" class="icon-btn-destructive cursor-pointer" title="Remove">
  <% if f.object.persisted? %>
    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
  <% else %>
    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
  <% end %>
</button>
```

### Rails `button_to` gotcha

`button_to` generates a `<form>` wrapper that breaks flex/grid layout. **Always** pass `form_class: "contents"` to make the form wrapper invisible to layout:

```erb
<%= button_to path, method: :delete, form_class: "contents", class: "icon-btn-destructive" do %>
```

---

## Index Pages

### Page Header
```erb
<div class="flex justify-between items-center mb-6">
  <h1 class="text-2xl font-bold text-gray-900">Resources</h1>
  <%= link_to "New Resource", new_admin_resource_path, class: "btn-admin" %>
</div>
```

### Tables
```
table.min-w-full.divide-y.divide-gray-200
  thead.bg-gray-50
    th.px-6.py-3.text-left.text-xs.font-medium.text-gray-500.uppercase.tracking-wider
  tbody.bg-white.divide-y.divide-gray-200
    td.px-6.py-4
```

### Row Navigation
- The primary identifier (name, title, invoice number) is a clickable `link_to` the show page.
- No "View" or "Show" buttons.

### Row Actions
- Secondary actions (Edit, Delete) appear as a **joined icon button group**, right-aligned in the last column.
- Max 2-3 icon buttons per group. If 4+ actions are ever needed, use a hamburger/overflow menu.
- The actions column header is empty (`<th class="px-6 py-3"></th>`).

---

## Show Pages

### Layout
```erb
<%# Back link — always above the card %>
<%= link_to "&larr; Back to Resources".html_safe, admin_resources_path, class: "text-sm text-gray-500 hover:text-gray-700 mb-4 inline-block" %>

<%# Main card %>
<div class="bg-white rounded-xl shadow-sm p-6">
  <%# Header row: title left, status badge + icon group right %>
  <div class="flex justify-between items-start mb-6">
    <div>
      <h1 class="text-2xl font-bold text-gray-900">Resource Name</h1>
    </div>
    <div class="flex items-center gap-3">
      <span class="...status badge...">Status</span>
      <div class="icon-btn-group">
        <%# edit + delete icons (w-5 h-5) %>
      </div>
    </div>
  </div>
  <%# Content... %>
</div>
```

### Grid Layout
- Resources with metadata sidebars: `grid grid-cols-1 lg:grid-cols-3 gap-6` (content spans 2, sidebar spans 1)
- Simple resources (invoices, order forms, attachments): single column

---

## Cards and Sections

- Standard card: `bg-white rounded-xl shadow-sm p-6`
- Filter bars: `bg-white rounded-xl shadow-sm p-4`
- Section headings inside cards: `<h2 class="text-lg font-semibold text-gray-900">`
- Subsection dividers: `border-t border-gray-100 pt-4 mt-4`

---

## Status Badges

- In tables: `inline-block px-2 py-1 rounded-full text-xs font-medium`
- Featured on show pages: `inline-block px-3 py-1 rounded-full text-sm font-medium`
- Color helper provides the bg/text color classes per status.

---

## Forms (Edit/New Pages)

### Page Structure
```erb
<%= link_to "&larr; Back".html_safe, admin_resources_path, class: "text-sm text-gray-500 hover:text-gray-700 mb-4 inline-block" %>
<h1 class="text-2xl font-bold text-gray-900 mb-6">Edit Resource</h1>
<%= render "form", resource: @resource %>
```

### Form Layout
- Wrap sections in `bg-white rounded-xl shadow-sm p-6 space-y-5`
- Section headings: `<h2 class="text-lg font-semibold text-gray-900">`
- Labels: `block text-sm font-semibold text-gray-700 mb-1.5`
- Inputs: `input-admin w-full`
- Grid for side-by-side fields: `grid grid-cols-1 md:grid-cols-2 gap-5`

### Form Actions
```erb
<div class="flex justify-end gap-3">
  <%= link_to "Cancel", admin_resources_path, class: "btn-admin-secondary" %>
  <%= f.submit "Save", class: "btn-admin" %>
</div>
```

---

## Date Fields

Use Flatpickr via the `flatpickr` Stimulus controller:
```erb
<%= f.text_field :date_field, value: resource.date_field&.iso8601, class: "input-admin w-full", data: { controller: "flatpickr" } %>
```

---

## Typography

| Element | Classes |
|---|---|
| Page title (h1) | `text-2xl font-bold text-gray-900` |
| Section heading (h2) | `text-lg font-semibold text-gray-900` |
| Labels | `text-sm font-semibold text-gray-700` |
| Helper text | `text-sm text-gray-500` |
| Fine print | `text-xs text-gray-400` |
