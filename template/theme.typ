#let theme = (:)

#{
  for (key, value) in json(sys.inputs.THEME).at(sys.inputs.FLAVOR).colors {
    theme.insert(key, rgb(value.hex))
  }
  theme.insert("accent", theme.at(sys.inputs.ACCENT))
}
