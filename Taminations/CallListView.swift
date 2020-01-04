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

class CallListView : LinearLayout {

  private let callList = Application.isLandscape
    ? MultiColumnLayout()
    : CachingLinearLayout(indexed: true)
  let searchInput = TextInput()

  init() {
    super.init(.VERTICAL)
    searchInput.hint = "Search Calls"
    searchInput.textSize = 36.sp
    appendView(searchInput)
    searchInput.fillHorizontal()
    searchInput.returnAction {
      self.searchInput.blur()
    }
    callList.weight = 1
    appendView(callList)
    callList.fillHorizontal()
  }

  func clearItems() {
    callList.clear()
    searchInput.textSize = 36.sp  // in case user changed setting
  }

  func addItem(_ item:CallListData) {
    let panel = SelectablePanel()
    panel.backgroundColor = LevelObject.find(item.link).color
    let callname = TextView(item.title)
    callname.wrap()
    callname.textSize = 36.sp
    callname.weight = 1
    panel.appendView(callname)
    callname.fillVertical()
    callList.appendView(panel)
    panel.clickAction {
      self.searchInput.blur()
      Application.app.sendMessage(Request.Action.CALLITEM,
        ("link",item.link),
        ("level",item.link),
        ("title",item.title))
    }
  }

  override func invalidate() {
    callList.invalidate()
  }
}
