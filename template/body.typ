#import "data.typ": data
#import "theme.typ": theme

#let header = block(
  fill: theme.crust,
  width: 100%,
  outset: (left: 16pt),
  inset: (left: 0pt, rest: 16pt),
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

#let profile = block(breakable: false)[
  = #data.labels.profile
  #for paragraph in data.profile [
    #block[#paragraph]
  ]
]

#let cv_item(year, name, location, highlights) = block(breakable: false, inset: (left: -2pt, right: -2pt))[
  #grid(
    columns: (72pt, 1fr, auto),
    rows: (auto),
    column-gutter: 0pt,
    inset: (left: 2pt, right: 2pt, top: 8pt, bottom: 8pt),
    text(fill: theme.subtext0)[#year],
    strong(name),
    align(right, location),
    grid.hline(stroke: 0.5pt + theme.overlay0),
    [],
    grid.cell(colspan: 2, list(..highlights)),
  )
]

#let work_experience = [
  = #data.labels.work_experience
  #for e in data.work_experience [
    #cv_item(
      e.at("year", default: ""),
      e.at("position", default: ""),
      e.at("company", default: ""),
      e.at("highlights", default: ()),
    )
  ]
]

#let education = [
  = #data.labels.education
  #for e in data.education [
    #cv_item(
      e.at("year", default: ""),
      e.at("degree", default: ""),
      e.at("school", default: ""),
      e.at("highlights", default: ()),
    )
  ]
]

#block(inset: 16pt)[
  #let content = ()
  #content.push(header)
  #if data.profile.len() > 0 { content.push(profile) }
  #if data.work_experience.len() > 0 { content.push(work_experience) }
  #if data.education.len() > 0 { content.push(education) }
  #stack(spacing: 24pt, ..content)
]
