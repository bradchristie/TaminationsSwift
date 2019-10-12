/*

  Taminations Square Dance Animations
  Copyright (C) 2019 Brad Christie

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

class SettingsView : ScrollingLinearLayout {

  private var colorDancer:Int = 0

  private func radioButtons(_ title:String, default:String, _ buttons:(String,String)...) {
    let layout = LinearLayout(.VERTICAL)
    layout.backgroundColor = UIColor.FLOOR
    layout.bottomMargin = 10
    layout.topBorder = 3
    layout.fillHorizontal()
    appendView(layout)
    let titleView = TextView(title)
    titleView.textSize = 24
    titleView.textStyle = "bold"
    titleView.leftMargin = 10
    titleView.topMargin = 8
    titleView.alignLeft()
    titleView.fillHorizontal()
    layout.appendView(titleView)
    let currentValue = Setting(title).s ?? `default`
    let hintView = TextView("")
    let groupLine = LinearLayout(.HORIZONTAL)
    let group = RadioGroup()
    buttons.forEach { (text,hint) in
      let button = group.addButton(text)
      if (text == currentValue) {
        button.isChecked = true
        hintView.text = hint
      }
      button.clickAction {
        Setting(title).s = text
        Application.app.sendMessage(.SETTINGS_CHANGED)
        if (!hint.isBlank) {
          hintView.text = hint
        }
      }
    }
    group.backgroundColor = UIColor.white
    group.leftMargin = 10
    group.alignLeft()
    group.fillVertical()
    groupLine.appendView(group)
    let filler = View()
    filler.weight = 1
    groupLine.appendView(filler)
    groupLine.fillHorizontal()
    layout.appendView(groupLine)
    hintView.leftMargin = 10
    if (buttons.first { !$0.1.isBlank } != nil) {
      layout.appendView(hintView)
      hintView.alignLeft()
      hintView.fillHorizontal()
    }
  }

  private func checkBox(_ text:String, _ hint:String, _ default:Bool=false) {
    let layout = LinearLayout(.VERTICAL)
    layout.backgroundColor = UIColor.FLOOR
    layout.bottomMargin = 10
    layout.topBorder = 3
    layout.fillHorizontal()
    appendView(layout)
    let line = LinearLayout(.HORIZONTAL)
    line.topMargin = 10
    line.leftMargin = 10
    line.alignLeft()
    layout.appendView(line)
    let box = CheckBox()
    box.clickAction {
    //  self.layoutChildren()
      Setting(text).b = box.isChecked
      Application.app.sendMessage(.SETTINGS_CHANGED)
    }
    box.isChecked = Setting(text).b ?? `default`
    box.fillVertical()
    line.appendView(box)
    let title = TextView(text)
    title.textSize = 24
    title.textStyle = "bold"
    title.leftMargin = 10
    title.fillVertical()
    title.weight = 1
    line.appendView(title)
    let hintView = TextView(hint)
    hintView.leftMargin = 10
    hintView.wrap()
    //hintView.alignLeft()
    hintView.fillHorizontal()
    layout.appendView(hintView)
  }

  private func colorForCouple(_ name:String) -> UIColor {
    if let userColor = Setting(name).s {
      return UIColor.colorForName(userColor)
    }
    switch (name) {
      case "Couple 1" : return UIColor.red
      case "Couple 2" : return UIColor.green
      case "Couple 3" : return UIColor.blue
      case "Couple 4" : return UIColor.yellow
      default : return UIColor.white
    }
  }

  private func dancerColors(withRadio:Bool) {
    let layout = LinearLayout(.VERTICAL)
    layout.backgroundColor = UIColor.FLOOR
    layout.bottomMargin = 10
    layout.topBorder = 3
    if (withRadio) {
      radioButtons("Dancer Colors", default: "By Couple", 
        ("By Couple",""),
        ("Random",""),
        ("None",""))
    } else {
      let titleView = TextView("Dancer Colors")
      titleView.textSize = 24
      titleView.textStyle = "bold"
      titleView.leftMargin = 10
      titleView.topMargin = 8
      titleView.alignLeft()
      titleView.fillHorizontal()
      layout.appendView(titleView)
    }
    let colorBar = LinearLayout(.HORIZONTAL)
    let colorNames = ["black","blue","cyan","gray","green","magenta",
                      "orange","red","white","yellow"]
    var dancerColor:[TextView] = []
    colorNames.forEach { cname in
      let c = UIColor.colorForName(cname)
      let cs = SelectablePanel()
      let t = TextView("  ")
      t.backgroundColor = c
      t.alignLeft()
      t.fillVertical()
      t.weight = 1
      cs.appendView(t)
      cs.fillVertical()
      cs.weight = 1
      colorBar.appendView(cs)
      cs.clickAction {
        if (self.colorDancer > 0) {
          let textView = dancerColor[self.colorDancer-1]
          textView.backgroundColor = c
          textView.textColor = (c == UIColor.black || c == UIColor.blue)
            ? UIColor.white : UIColor.black
          Setting("Couple \(self.colorDancer)").s = cname
          Application.app.sendMessage(.SETTINGS_CHANGED)
        }
      }
    }
    let dancerLine = LinearLayout(.HORIZONTAL)
    let connectorLine = LinearLayout(.HORIZONTAL)
    var connectors:[TextView] = []
    for i in 1...4 {
      let dancerPanel = LinearLayout(.VERTICAL)
      let dancerSelector = SelectablePanel()
      let text = TextView("    \(i)    ")
      let color = colorForCouple("Couple \(i)")
      text.backgroundColor = color
      text.textColor = (color == UIColor.black || color == UIColor.blue)
        ? UIColor.white : UIColor.black
      text.fillParent()
      dancerColor.append(text)
      dancerSelector.appendView(text)
      dancerPanel.leftMargin = 10
      dancerPanel.rightMargin = 10
      let connector = TextView("  |       ")
      connector.backgroundColor = UIColor.FLOOR
      connector.textColor = UIColor.FLOOR
      connector.alignMiddle()
      connector.fillParent()
      connectors.append(connector)
      dancerSelector.clickAction {
        connectors.forEach { c in c.textColor = UIColor.FLOOR }
        if (self.colorDancer == i) {
          self.colorDancer = 0
          connector.textColor = UIColor.FLOOR
        } else {
          self.colorDancer = i
          connector.textColor = UIColor.black
        }
      }
    //  dancerSelector.fillVertical()
      dancerSelector.fillVertical()
      dancerLine.appendView(dancerSelector)
      connectorLine.appendView(connector)
    }
    layout.fillHorizontal()
    colorBar.fillHorizontal()
    let barFiller = View()
    barFiller.weight = 1
    //dancerLine.appendView(dancerBar)
    dancerLine.alignLeft()
    layout.appendView(dancerLine)
    connectorLine.alignLeft()
    layout.appendView(connectorLine)
    layout.appendView(colorBar)
    appendView(layout)
  }

  func showAnimationSettings() {
    clear()
    backgroundColor = UIColor.white
    radioButtons("Dancer Speed",default:"Normal",
      ("Slow","Dancers move at a Slow pace"),
      ("Normal","Dancers move at a Normal pace"),
      ("Fast","Dancers move at a Fast pace")
      )
    checkBox("Loop","Repeat the animation continuously")
    checkBox("Grid","Show a dancer-sized grid")
    checkBox("Paths","Draw a line for each dancer's route")
    radioButtons("Numbers",default:"None",
      ("None","Dancers not numbered"),
      ("Dancers","Number dancers 1-8"),
      ("Couples","Number couples 1-4")
    )
    dancerColors(withRadio: false)
    checkBox("Phantoms","Show phantom dancers where used for Challenge calls")
    radioButtons("Special Geometry",default:"None",
      ("None",""),
      ("Hexagon",""),
      ("Bi-gon","")
      )
    radioButtons("Transitions",default:"Fade",
      ("None",""),
      ("Fade",""),
      ("Fade and Zoom","")
    )
    radioButtons("Language for Definitions",default:"System",
      ("System", "Prefer system language, else English"),
      ("English", "Always show English"),
      ("German", "Prefer German, else English"),
      ("Japanese", "Prefer Japanese, else English"))

    checkBox("Dynamic Type","Adjust font size according to System Setting")
    checkBox("Tips","Show Tip of the Day at startup",true)
  }

  func showSequencerSettings() {
    clear()
    backgroundColor = UIColor.lightGray
    radioButtons("Starting Formation",default: "Squared Set",
      ("Facing Couples",""),
      ("Squared Set",""),
      ("Normal Lines",""))
    radioButtons("Dancer Speed",default:"Normal",
      ("Slow","Dancers move at a Slow pace"),
      ("Normal","Dancers move at a Normal pace"),
      ("Fast","Dancers move at a Fast pace")
    )
    checkBox("Grid","Show a dancer-sized grid")
    dancerColors(withRadio: true)
    checkBox("Dancer Shapes", "", true)
    radioButtons("Dancer Identification",default: "None",
      ("None", ""),
      ("Numbers",""),
      ("Couples",""),
      ("Names",""))
  }

}
