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

#let inputData = if "INPUT_JSON" in sys.inputs and sys.inputs.INPUT_JSON != "" {
  json(sys.inputs.INPUT_JSON)
} else { (:) }

#let jsonDir = sys.inputs.INPUT_JSON.split("/").slice(0, -1).join("/")
#let getPath(path) = if (path.starts-with("/")) { path } else { jsonDir + "/" + path }

#let overrideData = if "OVERRIDE" in sys.inputs and sys.inputs.OVERRIDE != "" {
  json.decode(sys.inputs.OVERRIDE)
} else { (:) }

#let merge(x, y) = if type(x) != type(y) {
  y
} else if type(x) == dictionary {
  let result = x
  for (k, v) in y {
    if k in result {
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

#let data = mergeAll((defaultData, inputData, overrideData))
