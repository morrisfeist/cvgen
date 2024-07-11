#import "theme.typ": theme
#import "data.typ": data

#let background() = block[
  #rect(fill: theme.base, height: 100%, width: 100%)
]

#set page(
  margin: (inside: 0pt, outside: 0pt, top: 0pt, bottom: 0pt),
  background: background(),
)

#set text(font: "Aileron", size: 10pt, fill: theme.text);

= TODO
#data.name
