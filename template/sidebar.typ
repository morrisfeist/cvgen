#import "data.typ": data
#import "theme.typ": theme

#let photo = rect(width: 100%, height: 25%, fill: theme.accent)

#let languages = [
  = #data.labels.languages
]

#let skills = [
  = #data.labels.skills
]

#let personal_details = [
  = #data.labels.personal_details
]

#let contact = [
  = #data.labels.contact
]

#let sidebar = rect(
  fill: theme.crust,
  inset: 16pt,
  height: 100%,
  width: 100%,
)[
  #stack(spacing: 24pt, photo, languages, skills, personal_details, contact)
]
