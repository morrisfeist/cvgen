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
      text(size: 18pt, fill: theme.primary, strong(data.name)),
      line(stroke: 2pt + theme.primary, length: 40%),
      text(size: 14pt, data.job_title),
    )
  ]
]

#let profile = block[
  = #data.labels.profile
  #for paragraph in data.profile [
    #block[#paragraph]
  ]
]

#let cv_item(year, name, location, highlights) = block(inset: (left: -2pt, right: -2pt))[
  #grid(
    columns: (72pt, 1fr, auto),
    rows: (auto),
    column-gutter: 0pt,
    inset: (left: 2pt, right: 2pt, top: 8pt, bottom: 8pt),
    text(fill: theme.subtext0)[#year],
    strong(name),
    align(right, location),
    grid.hline(stroke: 0.5pt + theme.overlay0),
    block[],
    grid.cell(colspan: 2, list(..highlights)),
  )
]

#let work_experience = [
  = #data.labels.work_experience
  #for e in data.work_experience [
    #cv_item(e.year, e.position, e.company, e.highlights)
  ]
]

#let education = [
  = #data.labels.education
  #for e in data.education [
    #cv_item(e.year, e.degree, e.school, e.highlights)
  ]
]

#rect(fill: theme.base, inset: 16pt, height: 100%, width: 100%)[
  #stack(spacing: 24pt, header, profile, work_experience, education)
]
