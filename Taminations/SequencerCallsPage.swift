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

class SequencerCallsPage : Page {

  private let _view = LinearLayout(.VERTICAL)
  override var view:View { return _view }

  let textInput = TextInput()
  private let callList = ScrollingLinearLayout()
  let errorText = TextView("")
  private var highlightedCall = -1
  private var savedBackground = UIColor.black
  let mike = MikeShape()
  let mikeButton:ImageButton
  var listening = false

  override init() {
    mikeButton = ImageButton(mike)
    super.init()
    _view.backgroundColor = UIColor.lightGray
    _view.rightBorder = 1
    callList.fillHorizontal()
    callList.weight = 1
    let editLine = LinearLayout(.HORIZONTAL)
    editLine.appendView(textInput)
    textInput.textSize = 36.sp
    textInput.fillVertical()
    textInput.weight = 1
    textInput.bottomBorder = 1
    textInput.topMargin = 4
    textInput.bottomMargin = 4
    textInput.leftMargin = 12
    textInput.rightMargin = 12
    mikeButton.height = 52
    mikeButton.width = 52
    mikeButton.rightMargin = 10
    mikeButton.weight = 0
    mikeButton.alignCenter()
    editLine.appendView(mikeButton)
    mikeButton.clickAction {
      self.listening = !self.listening
      self.mike.color = self.listening ? UIColor.red : UIColor.black
      Application.app.sendMessage(.SEQUENCER_LISTEN)
    }
    editLine.weight = 0
    editLine.fillHorizontal()
    _view.appendView(editLine)
    _view.appendView(callList)
    errorText.backgroundColor = UIColor.white
    errorText.textColor = UIColor.red
    errorText.leftMargin = 4
    errorText.fillHorizontal()
    errorText.wrap()
    errorText.weight = 0
    _view.appendView(errorText)
  }

  func addCall(_ call:String, level:LevelData) {
    let callLine = SelectablePanel()
    let item = callList.items.count
    callLine.clickAction {
      Application.app.sendMessage(.SEQUENCER_CURRENTCALL,
        ("item", "\(item)"))
    }
    callLine.backgroundColor = level.color
    callLine.weight = 0
    let callText = TextView(call)
    callText.textSize = 36.sp
    callText.weight = 1
    callText.topMargin = 4
    callText.bottomMargin = 4
    callText.rightMargin = 12
    callText.leftMargin = 4
    callLine.appendView(callText)
    callText.fillVertical()
    let levelText = TextView(level.name)
    levelText.textSize = 12
    levelText.weight = 0
    callLine.appendView(levelText)
    levelText.fillVertical()
    callList.appendView(callLine)
    callLine.fillHorizontal()
    callList.scrollToBottom()
  }

  func highlightCall(_ call:Int) {
    if (highlightedCall >= 0) {
      callList.items[highlightedCall].backgroundColor = savedBackground
    }
    if (call >= 0 && call < callList.items.count) {
      let v = callList.items[call]
      savedBackground = v.backgroundColor
      v.backgroundColor = UIColor.yellow
      highlightedCall = call
      callList.scrollToItem(call)
    } else {
      highlightedCall = -1
    }
  }

  func removeLastCall() {
    callList.removeView(callList.items[callList.items.count-1])
    if (highlightedCall >= callList.items.count) {
      highlightedCall = -1
    }
  }

  func clearError() {
    errorText.text = ""
    errorText.hide()
  }

  func clear() {
    callList.clear()
    clearError()
    textInput.text = ""
    highlightedCall = -1
  }

}
