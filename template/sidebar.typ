#import "data.typ": data
#import "theme.typ": theme

#let photo = if data.photo != "" [
  #image(data.photo, width: 100%),
] else [
  #block(
    width: 100%,
    height: 25%,
    fill: gradient.linear(theme.primary, theme.secondary, angle: 305deg),
  )[
    #align(center + horizon)[
      #text(size: 16pt, fill: theme.crust)[PHOTO]
    ]
  ]
]

#let progress(name, proficiency, percent) = {
  let bar_radius = 2pt
  let bar_overhang = bar_radius
  block[
    #grid(
      columns: (1fr, auto),
      row-gutter: 4pt,
      strong[#name],
      text(fill: theme.primary)[#proficiency],
      grid.cell(
        colspan: 2,
        inset: (x: -bar_overhang, y: 0pt),
        block(
          fill: theme.surface0,
          width: 100%,
          height: 2 * bar_radius,
          radius: bar_radius,
          block(
            fill: gradient.linear(theme.primary, theme.secondary, relative: "parent"),
            width: percent,
            height: 100%,
            radius: bar_radius,
          ),
        ),
      ),
    )
  ]
}

#let languages = [
  #block[= #data.labels.languages]
  #stack(
    spacing: 14pt,
    ..data.languages.pairs().map(((k, v)) => progress(k, v.at(0), eval(v.at(1)))),
  )
]

#let skills = [
  #block[= #data.labels.skills]
  #stack(
    spacing: 14pt,
    ..data.skills.pairs().map(((k, v)) => progress(k, v.at(0), eval(v.at(1)))),
  )
]

#let icon(str) = box(
  inset: (top: -1pt),
)[
  #text(10pt, font: "Font Awesome 6 Free Solid", fill: theme.primary, str)
]

#let personal_details = [
  #let content = ()

  #if "name" in data.personal_details {
    content.push(icon[])
    content.push(text(data.personal_details.name))
  }

  #if "birthdate" in data.personal_details {
    content.push(icon[])
    content.push(text(data.personal_details.birthdate))
  }

  #if "website" in data.personal_details {
    content.push(icon[])
    content.push(link(
      "https://" + data.personal_details.website,
    )[#data.personal_details.website])
  }

  #if "permit" in data.personal_details {
    content.push(icon[])
    content.push(text(data.personal_details.permit))
  }

  #block[= #data.labels.personal_details]
  #grid(
    columns: (auto, auto),
    column-gutter: 8pt,
    row-gutter: 12pt,
    align: (center, start),
    ..content,
  )
]

#let contact = [
  #let content = ()

  #if "phone" in data.contact {
    content.push(icon[])
    content.push(link("tel:" + data.contact.phone))
  }

  #if "email" in data.contact {
    content.push(icon[])
    content.push(link("mailto:" + data.contact.email))
  }

  #if "github" in data.contact {
    content.push(icon[])
    content.push(
      link("https://github.com/" + data.contact.github)[#data.contact.github],
    )
  }

  #if "address" in data.contact {
    content.push(icon[])
    content.push(text(data.contact.address))
  }

  #block[= #data.labels.contact]
  #grid(
    columns: (auto, auto),
    column-gutter: 8pt,
    row-gutter: 12pt,
    align: (center, start),
    ..content,
  )
]

#block(fill: theme.crust, inset: 16pt, height: 100%, width: 100%)[
  #let content = ()
  #content.push(photo)
  #if data.languages.len() > 0 { content.push(languages) }
  #if data.skills.len() > 0 { content.push(skills) }
  #if data.personal_details.len() > 0 { content.push(personal_details) }
  #if data.contact.len() > 0 { content.push(contact) }
  #stack(spacing: 24pt, ..content)
]
