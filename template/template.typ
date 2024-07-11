#import "theme.typ": theme

#let background() = block[
  #rect(fill: theme.base, height: 100%, width: 100%)
]

#set page(
  margin: (inside: 0pt, outside: 0pt, top: 0pt, bottom: 0pt),
  background: background(),
)

#set text(font: "Liberation Sans", size: 10pt, fill: theme.text);

#show heading: set text(theme.primary)

#grid(columns: (30fr, 70fr), include "sidebar.typ", include "body.typ")
