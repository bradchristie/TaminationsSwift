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

class LevelPage : Page {

  private var _view = LevelView()
  override var view:View { get { return _view }}

  override func doRequest(_ request: Request) -> Bool {
    if (request.action == Request.Action.LEVEL) {
      return true
    }
    if (request.action == Request.Action.STARTUP && Application.isPortrait) {
      Application.app.titleBar.title = "Taminations"
      Application.app.titleBar.level = " "
      return true
    }
    return false
  }

  override func canDoAction(_ action: Request.Action) -> Bool {
    return action == Request.Action.LEVEL ||
      ( /* Application.isPortrait  && */ action == Request.Action.STARTUP  )
  }

  override init() {
    _view.levelAction = { level in
      var action = Request.Action.CALLLIST
      if (level == "About") {
        action = Request.Action.ABOUT
      }
      if (level == "Settings") {
        action = Request.Action.SETTINGS
      }
      if (level == "Sequencer") {
        action = Request.Action.SEQUENCER
      }
      if (level == "Practice") {
        action = Request.Action.STARTPRACTICE
      }
      Application.app.sendRequest(action,("level",level))
    }
  }

}

class LevelView : LinearLayout {

  var levelAction:(String)->() = { _ in }

  init() {
    super.init(LinearLayout.Direction.VERTICAL)
    backgroundColor = LevelObject.find("all").color
    rightBorder = 1
    //  Basic and Mainstream
    appendLine(oneView("bms"))
    appendLine(indentedOneLevelView("bms", "b1"))
    appendLine(indentedOneLevelView("bms", "b2"))
    appendLine(indentedOneLevelView("bms", "ms"))
    appendLine(oneView("plus"))
    //  Advanced
    appendLine(oneView("adv"))
    appendLine(indentedOneLevelView("adv", "a1"))
    appendLine(indentedOneLevelView("adv", "a2"))
    //  Challenge
    appendLine(oneView("Challenge"))
    appendLine(indentedOneLevelView("Challenge", "c1"))
    appendLine(indentedOneLevelView("Challenge", "c2"))
    appendLine(indentedOneLevelView("Challenge", "c3a"))
    appendLine(indentedOneLevelView("Challenge", "c3b"))
    //  Other buttons
    appendLine(oneView("all","Index of All Calls"))
    //  Tweaks for putting two items on one line
    let line1 = LinearLayout(LinearLayout.Direction.HORIZONTAL)
    line1.weight = 1
    line1.topBorder = 1
    let pracItem = oneView("all","Practice")
    line1.appendView(pracItem).fillVertical()
    let seqItem = oneView("all","Sequencer")
    seqItem.leftBorder = 1
    line1.appendView(seqItem).fillVertical()
    appendLine(line1)
    let line2 = LinearLayout(LinearLayout.Direction.HORIZONTAL)
    line2.weight = 1
    line2.topBorder = 1
    let aboutItem = oneView("all","About")
    line2.appendView(aboutItem)
    aboutItem.fillVertical()
    let setItem = oneView("all","Settings")
    setItem.leftBorder = 1
    line2.appendView(setItem)
    setItem.fillVertical()
    appendLine(line2)
  }

  private func appendLine(_ view:View) {
    appendView(view)
    view.fillHorizontal()
  }

  private func oneLevelView(_ lev:String, _ text:String?=nil) -> View {
    let v = SelectablePanel()
    let level = LevelObject.find(lev)
    v.backgroundColor = level.color
    let label = text ?? level.name
    let textView = TextView(label)
    textView.textSize = 25.pp
    textView.textStyle = "bold"
    textView.leftMargin = 40.pp
    textView.weight = 1
    v.appendView(textView)
    textView.alignCenter()
    v.topBorder = 1
    v.clickAction { self.levelAction(label) }
    return v
  }

  private func oneView(_ lev:String, _ text:String?=nil) -> View {
    let v = oneLevelView(lev,text)
    v.weight = 1
    return v
  }

  private func indentedOneLevelView(_ lev:String,_ sublev:String) -> View {
    let v = LinearLayout(LinearLayout.Direction.HORIZONTAL)
    v.weight = 1
    let v1 = View()
    v1.backgroundColor = LevelObject.find(lev).color
    v.appendView(v1).weight(1).fillVertical()
    let v2 = oneView(sublev)
    v2.topBorder = 1
    v2.leftBorder = 1
    v.appendView(v2).weight(9).fillVertical()
    return v
  }

}
