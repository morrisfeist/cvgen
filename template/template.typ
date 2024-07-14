#import "theme.typ": theme

#set page(margin: 0pt, fill: theme.base)

#set text(font: "Liberation Sans", size: 10pt, fill: theme.text);

#show heading: set text(theme.primary)

#grid(columns: (30fr, 70fr), include "sidebar.typ", include "body.typ")
