#let inputData = json(sys.inputs.INPUT_JSON)

#let jsonDir = sys.inputs.INPUT_JSON.split("/").slice(0, -1).join("/")
#let getPath(path) = if (path.starts-with("/")) { path } else { jsonDir + "/" + path }

#let merge(x, y) = if type(x) != type(y) {
  y
} else if type(x) == dictionary {
  let result = x
  for (k, v) in y {
    if result.keys().contains(k) {
      result.insert(k, merge(result.at(k), v))
    } else {
      result.insert(k, v)
    }
  }
  result
} else if type(x) == array {
  (x, y).flatten()
} else {
  y
}

#let mergeAll(xs) = xs.fold((:), merge)

// Define defaults to make document generation more user error tolerant
#let defaultData = (
  theme: (flavor: "latte", primary: "peach", secondary: "yellow"),
  labels: (
    contact: "Contact",
    education: "Education",
    languages: "Languages",
    personal_details: "Personal Details",
    profile: "Profile",
    skills: "Skills",
    work_experience: "Work Experience",
  ),
  photo: "",
  name: "",
  job_title: "",
  languages: (:),
  skills: (:),
  personal_details: (:),
  contact: (:),
  profile: (),
  work_experience: (),
  education: (),
)

#let data = mergeAll((defaultData, inputData))
