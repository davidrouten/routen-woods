# Project Instructions

## Admin UI/UX

All admin views MUST follow the patterns in [STYLE_GUIDE.md](STYLE_GUIDE.md). Read it before creating or modifying any admin view. No one-off button styles, no layout deviations without updating the guide first.

## Rails + Tailwind Gotchas

- **`button_to` in flex/grid layouts**: Always pass `form_class: "contents"` — `button_to` generates a `<form>` wrapper that breaks layout otherwise.
- **Custom `@apply` classes**: Only `@apply` Tailwind utility classes in `components.css`, never other custom component classes (e.g. don't `@apply input-admin` — it fails on deploy).
- **Icon buttons**: Use the `icon-btn-group` / `icon-btn` / `icon-btn-destructive` component classes from `components.css`. Never write inline icon button styles.
