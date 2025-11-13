import std/tables, std/strformat

type Section* = ref object
  properties*: Table[string, string]

proc newSection*(): Section =
  result = Section()
  result.properties = initTable[string, string]()

proc setProperty*(this: Section, name: string, value: string) =
  this.properties[name] = value

proc `$`*(this: Section): string =
  result = &"<Section {$this.properties} >"


when isMainModule:
  var sec = newSection()
  doAssert(sec.properties.len == 0)

  sec.setProperty("key", "value")
  doAssert(sec.properties.len == 1)
  doAssert($sec == "<Section {\"key\": \"value\"} >")
