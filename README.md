# ini-nim
Yet another .ini parser. ([Original](https://xmonader.github.io/nimdays/day05_iniparser.html))

## How to use
```nim
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
```
