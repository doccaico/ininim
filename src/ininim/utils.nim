import std/tables, std/strutils, std/strformat
import ./section

type Ini = ref object
  sections: Table[string, Section]

proc newIni*(): Ini =
  result = Ini()
  result.sections = initTable[string, Section]()

proc `$`*(this: Ini): string =
  result = &"<Ini {$this.sections} >"

proc setSection*(this: Ini, name: string, section: Section) =
  this.sections[name] = section

proc getSection*(this: Ini, name: string): Section =
  result = this.sections.getOrDefault(name)

proc hasSection*(this: Ini, name: string): bool =
  result = this.sections.contains(name)

proc deleteSection*(this: Ini, name: string) =
  this.sections.del(name)

proc countSection*(this: Ini): int = 
  result = this.sections.len

# There are some helper procs.
proc hasProperty*(this: Ini, sectionName: string, key: string): bool=
  result = this.sections.contains(sectionName) and this.sections[sectionName].properties.contains(key)

proc setProperty*(this: Ini, sectionName: string, key: string, value: string) =
  when defined(debug): echo &"[Debug ini.setProperty] {this.sections}"
  if this.sections.contains(sectionName):
    this.sections[sectionName].setProperty(key, value)
  else:
    raise newException(ValueError, &"Ini doesn't have section: \"{sectionName}\"")

proc getProperty*(this: Ini, sectionName: string, key: string): string =
  when defined(debug): echo &"[Debug ini.getProperty] {this.sections}"
  if this.sections.contains(sectionName):
    result = this.sections[sectionName].properties.getOrDefault(key)
  else:
    raise newException(ValueError, &"Ini doesn't have section: \"{sectionName}\"")

proc deleteProperty*(this: Ini, sectionName: string, key: string) =
  when defined(debug): echo &"[Debug ini.deleteProperty] {this.sections}"
  if this.sections.contains(sectionName) and this.sections[sectionName].properties.contains(key):
    this.sections[sectionName].properties.del(key)
  else:
    raise newException(ValueError, &"Ini doesn't have section: \"{sectionName}\"")

proc toIniString*(this: Ini, sep: char = '='): string =
  for sectName, section in this.sections:
    result.add &"[{sectName}]\n"
    for k, v in section.properties:
      result.add &"{k} {sep} {v}\n"
    result.add "\n"

type ParserState = enum
  readSection
  readKV

proc parseIni*(s: string): Ini = 
  var ini = newIni()
  var state: ParserState = readSection
  let lines = s.splitLines
  var currentSectionName: string = ""

  for line in lines:
    if line.strip() == "" or line.startsWith(";") or line.startsWith("#"):
      continue
    if line.startsWith("[") and line.endsWith("]"):
      state = readSection
    if state == readSection:
      var currentSection = newSection()
      currentSectionName = line[1..<line.len-1]
      ini.setSection(currentSectionName, currentSection)
      state = readKV
      continue
    if state == readKV:
      let parts = line.split({'='})
      if len(parts) == 2:
        let key = parts[0].strip()
        let val = parts[1].strip()
        ini.setProperty(currentSectionName, key, val)
  return ini


when isMainModule:
  let sample = """

[general]
appname = configparser
version = 0.1

[author]
name = xmonader
email = notxmonader@gmail.com

  """

  var d = parseIni(sample)
  doAssert(d.countSection() == 2)

  doAssertRaises(ValueError):
    d.setProperty("notfound", "appname", "newappname")
    discard d.getProperty("notfound", "appname")
    d.deleteProperty("notfound", "name")

  doAssert(d.getProperty("general", "appname") == "configparser")
  doAssert(d.getProperty("general", "version") == "0.1")
  doAssert(d.getProperty("author", "name") == "xmonader")
  doAssert(d.getProperty("author", "email") == "notxmonader@gmail.com")

  d.setProperty("author", "email", "alsonotxmonader@gmail.com")
  doAssert(d.getProperty("author", "email") == "alsonotxmonader@gmail.com")
  doAssert(d.hasSection("general") == true)
  doAssert(d.hasSection("author") == true)
  doAssert(d.hasProperty("author", "name") == true)
  d.deleteProperty("author", "name")
  doAssert(d.hasProperty("author", "name") == false)
  doAssert($d.getSection("author") == "<Section {\"email\": \"alsonotxmonader@gmail.com\"} >")

  # echo d.toIniString()
