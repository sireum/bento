// #Sireum

import org.sireum._

val home = Os.home
val sireumHome = Os.path(Os.env("SIREUM_HOME").get)


/*******************************************************************************
 * Add application launchers to the desktop and the 'Applications >> Development' 
 * menu for:
 * - CLion
 * - OSATEK
 * - IVE
 ******************************************************************************/

def addDesktopEntry(name: String, exec: String, icon: String): Unit = {

  val entry = st"""[Desktop Entry]
                  |Version=1.0
                  |Type=Application
                  |Name=${name}
                  |Exec=${exec}
                  |Icon=${icon}
                  |Categories=Development;
                  |"""
  def emit(p: Os.Path): Unit = {
    p.writeOver(entry.render)
    p.chmod("700")
    println(s"Wrote: ${p}")
  }
  emit(home / ".local" / "share" / "applications" / s"${name}.desktop")
  emit(home / "Desktop" / s"${name}.desktop")
}

val clion = sireumHome / "bin" / "linux" / "clion" / "bin" / "clion.sh"
val fmide = sireumHome / "bin" / "linux" / "fmide" / "fmide"
val ive = sireumHome / "bin" / "linux" / "idea" / "bin" / "IVE.sh"

// launch with 'bash -i' so that the environment variables are available
addDesktopEntry("CLion", st"""bash -ic "${clion.value}"""".render, "clion")
addDesktopEntry("FMIDE", st"""bash -ic "GTK_THEME=Adwaita ${fmide.value}"""".render, "eclipse") // TODO: find an osate icon
addDesktopEntry("IVE", st"""bash -ic "${ive.value}"""".render, (ive.up / "idea.png").value)



/*******************************************************************************
 * Setup the tccoe22 subdirectory which includes:
 * - readme
 * - temperature control project
 *     - at least the starting point (i.e aadl but no codegen artifacts)
 *     - maybe final version that's sel4 ready?
 * - slides
 * - links to videos/presentasi material?
 ******************************************************************************/

val tccoe22Dir = home / "tccoe22"
tccoe22Dir.removeAll()
tccoe22Dir.mkdir()

val tempControlRepo = "https://github.com/jasonbelt/test" // TODO: change to final repo location

proc"git clone ${tempControlRepo} temperature_control".at(tccoe22Dir).console.runCheck()
