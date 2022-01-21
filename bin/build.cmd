::#! 2> /dev/null                                   #
@ 2>/dev/null # 2>nul & echo off & goto BOF         #
if [ -z ${SIREUM_HOME} ]; then                      #
  echo "Please set SIREUM_HOME env var"             #
  exit -1                                           #
fi                                                  #
exec ${SIREUM_HOME}/bin/sireum slang run "$0" "$@"  #
:BOF
setlocal
if not defined SIREUM_HOME (
  echo Please set SIREUM_HOME env var
  exit /B -1
)
%SIREUM_HOME%\bin\sireum.bat slang run "%0" %*
exit /B %errorlevel%
::!#
// #Sireum

import org.sireum._

if (Os.cliArgs.isEmpty) {
  println("Usage: ( clean | desktop | base | sel4 | sireum )+")
  Os.exit(0)
}

val debianVer = "11.1"

val homeDir = Os.slashDir.up.canon
val buildsDir = homeDir / "builds"
val templatesDir = homeDir / "packer_templates" / "debian"

val nameDesktop = s"debian-$debianVer-desktop"
val nameBase = s"debian-$debianVer-desktop-seL4-base"
val nameSeL4 = s"debian-$debianVer-desktop-seL4"
val nameSireum = s"debian-$debianVer-desktop-seL4-sireum"

val boxDesktop = buildsDir / s"$nameDesktop.virtualbox.box"
val boxBase = buildsDir / s"$nameBase.virtualbox.box"
val boxSeL4 = buildsDir / s"$nameSeL4.virtualbox.box"
val boxSireum = buildsDir / s"$nameSireum.virtualbox.box"

val scriptsDir = templatesDir / "scripts"
val sourcesBase = ISZ(templatesDir / s"$nameBase.json", scriptsDir / "seL4.sh")
val sourcesSeL4 = ISZ(templatesDir / s"$nameSeL4.json", scriptsDir / "test.sh")
val sourcesSireum = ISZ(templatesDir / s"$nameSireum.json", scriptsDir / "sireum-install.sh")
val sourcesDesktop: ISZ[Os.Path] = {
  var r = ISZ[Os.Path](
    templatesDir / "http" / "debian-9" / "preseed-sireum.cfg",
    templatesDir / s"$nameDesktop.json"
  )
  r = r ++ (for (p <- (templatesDir.up.canon / "_common").list if p.ext === "sh") yield p)
  r = r ++ (for (p <- scriptsDir.list if p.ext === "sh") yield p)
  r = r -- sourcesBase -- sourcesSeL4 -- sourcesSireum
  r
}

var desktopBuilt = F
var baseBuilt = F
var sel4Built = F
var sireumBuilt = F

def sha3src(sources: ISZ[Os.Path]): String = {
  val sha3 = crypto.SHA3.init256
  for (src <- sources) {
    sha3.update(conversions.String.toU8is(src.read))
  }
  return st"${(sha3.finalise(), "")}".render
}

def work(box: Os.Path, sum: String, f: () => Unit): Unit = {
  val p = box.up.canon / s"${box.name}.sources.sha3"
  if (!p.exists || p.read != sum) {
    println(s"Creating $box ...")
    f()
    p.up.mkdirAll()
    p.writeOver(sum)
    println()
  } else {
    println(s"Skipped creating $box")
    println()
  }
}

def buildDesktop(): Unit = {
  if (desktopBuilt) {
    return
  }
  def f(): Unit = {
    (buildsDir / nameDesktop).removeAll()
    proc"packer build -only=virtualbox-iso $nameDesktop.json".at(templatesDir).echo.console.runCheck()
  }
  work(boxDesktop, sha3src(sourcesDesktop), f _)
  desktopBuilt = T
}

def buildBase(): Unit = {
  if (baseBuilt) {
    return
  }
  def f(): Unit = {
    buildDesktop()
    val temp = buildsDir / nameDesktop
    temp.removeAll()
    temp.mkdirAll()
    proc"tar xf $boxDesktop".at(temp).echo.console.runCheck()
    (buildsDir / nameBase).removeAll()
    proc"packer build -only=virtualbox-ovf $nameBase.json".at(templatesDir).echo.console.runCheck()
    temp.removeAll()
  }
  work(boxBase, sha3src(sourcesBase), f _)
  baseBuilt = T
}

def buildSeL4(): Unit = {
  if (sel4Built) {
    return
  }
  def f(): Unit = {
    buildBase()
    val temp = buildsDir / nameBase
    temp.removeAll()
    temp.mkdirAll()
    proc"tar xf $boxBase".at(temp).echo.console.runCheck()
    (buildsDir / nameSeL4).removeAll()
    proc"packer build -only=virtualbox-ovf $nameSeL4.json".at(templatesDir).echo.console.runCheck()
    temp.removeAll()
    val ova = buildsDir / nameSeL4 / s"$nameSeL4.ova"
    ova.moveOverTo(buildsDir / ova.name)
    ova.up.removeAll()
  }
  work(boxSeL4, sha3src(sourcesSeL4), f _)
  sel4Built = T
}

def buildSireum(): Unit = {
  if (sireumBuilt) {
    return
  }
  def f(): Unit = {
    buildSeL4()
    val temp = buildsDir / nameSeL4
    temp.removeAll()
    temp.mkdirAll()
    proc"tar xf $boxSeL4".at(temp).echo.console.runCheck()
    (buildsDir / nameSireum).removeAll()
    proc"packer build -only=virtualbox-ovf $nameSireum.json".at(templatesDir).echo.console.runCheck()
    temp.removeAll()
    val ova = buildsDir / nameSireum / s"$nameSireum.ova"
    ova.moveOverTo(buildsDir / ova.name)
    ova.up.removeAll()
  }
  work(boxSireum, sha3src(sourcesSireum), f _)
  sireumBuilt = T
}

var tccoe22Built: B = F
def buildTccoe22(): Unit = {
  if (tccoe22Built) {
    return
  }
  val nameTccoe22 = s"debian-$debianVer-desktop-seL4-sireum-tccoe22"
  val boxTccoe22 = buildsDir / s"$nameTccoe22.virtualbox.box"
  val sourcesTccoe22 = ISZ(templatesDir / s"$nameTccoe22.json")

  def f(): Unit = {
    buildSireum()
    val temp = buildsDir / nameTccoe22
    temp.removeAll()
    temp.mkdirAll()
    proc"tar xf $boxSireum".at(temp).echo.console.runCheck()
    (buildsDir / nameTccoe22).removeAll()
    proc"packer build -only=virtualbox-ovf $nameTccoe22.json".at(templatesDir).echo.console.runCheck()
    temp.removeAll()
    val ova = buildsDir / nameTccoe22 / s"$nameTccoe22.ova"
    ova.moveOverTo(buildsDir / ova.name)
    ova.up.removeAll()
  }
  work(boxTccoe22, sha3src(sourcesTccoe22), f _)
  tccoe22Built = T
}

for (arg <- Os.cliArgs) {
  arg match {
    case string"desktop" => buildDesktop()
    case string"base" => buildBase()
    case string"sel4" => buildSeL4()
    case string"sireum" => buildSireum()
    case string"tccoe22" => buildTccoe22()
    case string"clean" =>
      for (p <- buildsDir.list if p.name != ".gitkeep") {
        p.removeAll()
      }
  }
}
