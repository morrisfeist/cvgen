#import "data.typ": data
#import "theme.typ": theme

#let photo = rect(
  width: 100%,
  height: 25%,
  fill: gradient.linear(theme.primary, theme.secondary),
)

#let progress(name, proficiency, percent) = block[
  #grid(
    columns: (1fr, auto),
    row-gutter: 4pt,
    strong[#name],
    text(fill: theme.primary)[#proficiency],
    grid.cell(
      colspan: 2,
      inset: (x: -2pt, y: 0pt),
      rect(
        fill: theme.surface0,
        width: 100%,
        height: 4pt,
        radius: 2pt,
        inset: 0pt,
        rect(
          fill: gradient.linear(theme.primary, theme.secondary, relative: "parent"),
          width: percent,
          height: 100%,
          radius: 2pt,
          inset: 0pt,
        ),
      ),
    ),
  )
]

#let languages = [
  = #data.labels.languages
  #grid(
    inset: (top: 8pt),
    row-gutter: 6pt,
    ..(
      data.languages.pairs().map(((k, v)) => progress(k, v.at(0), eval(v.at(1))))
    ),
  )
]

#let skills = [
  = #data.labels.skills
  #grid(
    inset: (top: 8pt),
    row-gutter: 6pt,
    ..(
      data.skills.pairs().map(((k, v)) => progress(k, v.at(0), eval(v.at(1))))
    ),
  )
]

#let personal_details = [
  = #data.labels.personal_details
]

#let contact = [
  = #data.labels.contact
]

#rect(
  fill: theme.crust,
  inset: 16pt,
  height: 100%,
  width: 100%,
)[
  #stack(spacing: 24pt, photo, languages, skills, personal_details, contact)
]
