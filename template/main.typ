#import "theme.typ": theme

#let background() = block[
  #rect(fill: theme.base, height: 100%, width: 100%)
]

#set page(
  margin: (inside: 0pt, outside: 0pt, top: 0pt, bottom: 0pt),
  background: background(),
)

= TODO
