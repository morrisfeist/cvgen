#let data = json(sys.inputs.INPUT_JSON)

#let jsonDir = sys.inputs.INPUT_JSON.split("/").slice(0, -1).join("/")
#let getPath(path) = if (path.starts-with("/")) { path } else { jsonDir + "/" + path }

#assert(
  data.at("name", default: "") != "",
  message: "Missing or empty property 'name'",
)
#assert(
  data.at("job_title", default: "") != "",
  message: "Missing or empty property 'job_title'",
)

// Define defaults to make document generation more user error tolerant
#data.insert("theme", data.at("theme", default: (:)))
#data.theme.insert("flavor", data.theme.at("flavor", default: "latte"))
#data.theme.insert("primary", data.theme.at("primary", default: "peach"))
#data.theme.insert("secondary", data.theme.at("secondary", default: "yellow"))

#data.insert("labels", data.at("labels", default: (:)))
#data.labels.insert("contact", data.labels.at("contact", default: "Contact"))
#data.labels.insert("education", data.labels.at("education", default: "Education"))
#data.labels.insert("languages", data.labels.at("languages", default: "Languages"))
#data.labels.insert("personal_details", data.labels.at("personal_details", default: "Personal Details"))

#data.insert("photo", data.at("photo", default: ""))
#if data.photo != "" { data.insert("photo", getPath(data.photo)) }

#data.labels.insert("profile", data.labels.at("profile", default: "Profile"))
#data.labels.insert("skills", data.labels.at("skills", default: "Skills"))
#data.labels.insert("work_experience", data.labels.at("work_experience", default: "Work Experience"))

#data.insert("languages", data.at("languages", default: (:)))
#data.insert("skills", data.at("skills", default: (:)))
#data.insert("personal_details", data.at("personal_details", default: (:)))
#data.insert("contact", data.at("contact", default: (:)))

#data.insert("profile", data.at("profile", default: ()))
#data.insert("work_experience", data.at("work_experience", default: ()))
#data.insert("education", data.at("education", default: ()))
