#let theme = (:)
#for (key, value) in json(sys.inputs.THEME).frappe.colors {
  theme.insert(key, rgb(value.hex))
}
