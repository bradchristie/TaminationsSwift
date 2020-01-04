/*

  Taminations Square Dance Animations
  Copyright (C) 2020 Brad Christie

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

import UIKit

class AnimationModel {

  let link:String
  var tamdoc:XMLDocument
  var tamcount = 0

  init(_ layout:AnimationLayout, _ link:String, anim:Int=(-1), name:String="") {
    self.link = link
    //  Fetch the XML animation and send it to the animation view
    tamdoc = TamUtils.getXMLAsset(link)
    let alltams = tamdoc.xpath("/tamination/*[@title]").filter {
      tam in !(tam.attr("display") ?? "").startsWith("n")
    }
    let tam = alltams[max(anim,0)]
    Application.app.titleBar.title = tam.attr("title")!
    let level = link.split("/").first!
    Application.app.titleBar.level = LevelObject.find(level).name
    layout.animationView.setAnimation(tam)
    if let tamsays = tam.firstChild(tag:"taminator") {
      let tamtext = "\(tamsays.childNodes(ofTypes:[.Text])[0])".replaceAll("\\s+"," ")
      layout.saysText.text = tamtext
    } else {
      layout.saysText.text = ""  // Could be hide() but this seems to work ok
    }
    tamcount = alltams.count

  }

}
