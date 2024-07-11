#import "data.typ": data
#import "theme.typ": theme

#let header = [
  = Header
]

#let profile = [
  = #data.labels.profile
]

#let work_experience = [
  = #data.labels.work_experience
]

#let education = [
  = #data.labels.education
]

#let body = rect(fill: theme.base, inset: 16pt, height: 100%, width: 100%)[
  #stack(spacing: 24pt, header, profile, work_experience, education)
]
