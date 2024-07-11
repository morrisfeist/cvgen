#import "theme.typ": theme

#import "body.typ": body
#import "sidebar.typ": sidebar

#let background() = block[
  #rect(fill: theme.base, height: 100%, width: 100%)
]

#set page(
  margin: (inside: 0pt, outside: 0pt, top: 0pt, bottom: 0pt),
  background: background(),
)

#set text(font: "Aileron", size: 10pt, fill: theme.text);

#grid(columns: (30fr, 70fr), sidebar, body)
