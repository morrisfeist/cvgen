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

#let inputData = if "JSON_FILE" in sys.inputs and sys.inputs.JSON_FILE != "" {
  json(sys.inputs.JSON_FILE)
} else { (:) }

#let getPath(path) = if path.starts-with("/") or "JSON_FILE" not in sys.inputs or sys.inputs.JSON_FILE == "" { path } else { sys.inputs.JSON_FILE.split("/").slice(0, -1).join("/") + "/" + path }

#let overrideData = if "JSON" in sys.inputs and sys.inputs.JSON != "" {
  json.decode(sys.inputs.JSON)
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

#if data.photo != "" {
  data.insert("photo", getPath(data.photo))
}
