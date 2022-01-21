// #Sireum

import org.sireum._

val home = Os.home
val sireumHome = Os.path(Os.env("SIREUM_HOME").get)

val applications = home / ".local" / "share" / "applications"
val desktop = home / "Desktop"

val clion = sireumHome / "bin" / "linux" / "clion" / "bin" / "clion.sh"
val fmide = sireumHome / "bin" / "linux" / "fmide" / "fmide"
val ive = sireumHome / "bin" / "linux" / "idea" / "bin" / "IVE.sh"

def addDesktopEntry(name: String, exec: String, icon: String): Unit = {

  val entry = st"""[Desktop Entry]
                  |Version=1.0
                  |Type=Application
                  |Name=${name}
                  |Exec=${exec}
                  |Icon=${icon}
                  |Categories=Development;
                  |"""

  val a = applications / s"${name}.desktop"
  val d = desktop / s"${name}.desktop"
  a.writeOver(entry.render)
  d.writeOver(entry.render)
  println(s"Wrote: ${a}")
  println(s"Wrote: ${d}")
}

addDesktopEntry("CLion", st"""bash -ic "${clion.value}"""".render, "clion")
addDesktopEntry("FMIDE", st"""bash -ic "GTK_THEME=Adwaita ${fmide.value}"""".render, "eclipse")
addDesktopEntry("IVE", st"""bash -ic "${ive.value}"""".render, (ive.up / "idea.png").value)

val tempControlRepo = "https://github.com/jasonbelt/test"
val tempControlDir = home / "temperature_control_test"

proc"git clone ${tempControlRepo} ${tempControlDir.value}".console.runCheck()
