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
  #block[= #data.labels.profile]
  #for paragraph in data.profile [
    #block[#paragraph]
  ]
]

#let cv_item(name, institution, year, location, highlights) = {
  let line_overhang = 4pt
  block(breakable: false, inset: (x: -line_overhang))[
    #grid(
      columns: (1fr, auto),
      align: (start, end),
      row-gutter: 4pt,
      inset: (x: line_overhang),
      strong[#name],
      text(fill: theme.subtext0)[#year],
      text(fill: theme.subtext0)[#institution],
      text(fill: theme.subtext0)[#location],
      grid.hline(stroke: 0.5pt + theme.overlay0),
      grid.cell(colspan: 2, inset: (x: line_overhang + 10pt, top: 8pt))[
        #list(..highlights)
      ],
    )
  ]
}

#let work_experience = [
  #block[= #data.labels.work_experience]
  #stack(spacing: 16pt, ..data.work_experience.map(e => [
    #cv_item(
      e.at("position", default: ""),
      e.at("company", default: ""),
      e.at("year", default: ""),
      e.at("location", default: ""),
      e.at("highlights", default: ()),
    )
  ]))
]

#let education = [
  #block[= #data.labels.education]
  #stack(spacing: 16pt, ..data.education.map(e => [
    #cv_item(
      e.at("degree", default: ""),
      e.at("school", default: ""),
      e.at("year", default: ""),
      e.at("location", default: ""),
      e.at("highlights", default: ()),
    )
  ]))
]

#block(inset: 16pt)[
  #let content = ()
  #content.push(header)
  #if data.profile.len() > 0 { content.push(profile) }
  #if data.work_experience.len() > 0 { content.push(work_experience) }
  #if data.education.len() > 0 { content.push(education) }
  #stack(spacing: 24pt, ..content)
]
