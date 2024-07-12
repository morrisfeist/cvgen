#import "data.typ": data

#let theme = (:)

#{
  for (key, value) in json(sys.inputs.THEME).at(data.theme.flavor).colors {
    theme.insert(key, rgb(value.hex))
  }
  theme.insert("primary", theme.at(data.theme.primary))
  theme.insert("secondary", theme.at(data.theme.secondary))
}
