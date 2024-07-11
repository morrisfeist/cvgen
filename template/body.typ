#import "data.typ": data
#import "theme.typ": theme

#let header = rect(
  fill: theme.crust,
  width: 100%,
  outset: (left: 24pt),
  inset: (left: 0pt, top: 16pt, right: 16pt, bottom: 16pt),
)[
  #align(horizon + start)[
    #stack(
      spacing: 16pt,
      text(size: 18pt, weight: "bold", fill: theme.accent, data.name),
      line(stroke: 2pt + theme.accent, length: 40%),
      text(size: 14pt, data.job_title),
    )
  ]
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
