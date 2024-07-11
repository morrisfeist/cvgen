#let theme = (:)

#{
  for (key, value) in json(sys.inputs.THEME).at(sys.inputs.FLAVOR).colors {
    theme.insert(key, rgb(value.hex))
  }
  theme.insert("primary", theme.at(sys.inputs.PRIMARY))
  theme.insert("secondary", theme.at(sys.inputs.SECONDARY))
}
