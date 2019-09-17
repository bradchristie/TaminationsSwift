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

class AnimListView : LinearLayout {

  let animlist = CachingLinearLayout()
  let keyView = LinearLayout(.HORIZONTAL)
  let buttonView = LinearLayout(.HORIZONTAL)
  var count:Int { get { return animlist.children.count } }

  init() {
    super.init(LinearLayout.Direction.VERTICAL)
    //  List of animations
    animlist.backgroundColor = UIColor.lightGray
    animlist.weight = 1
    animlist.fillHorizontal()
    appendView(animlist)

    //  Key for call difficulty
    keyView.weight = 0
    appendView(keyView)
    keyView.topBorder = 1
    keyView.fillHorizontal()
    let key1 = TextView("Common")
    key1.textSize = 30.pp
    key1.backgroundColor = UIColor.COMMON
    key1.weight = 1
    key1.alignMiddle()
    keyView.appendView(key1)
    key1.fillVertical()
    let key2 = TextView("Harder")
    key2.backgroundColor = UIColor.HARDER
    key2.textSize = 30.pp
    key2.weight = 1
    key2.alignMiddle()
    keyView.appendView(key2)
    key2.fillVertical()
    let key3 = TextView("Expert")
    key3.textSize = 30.pp
    key3.backgroundColor = UIColor.EXPERT
    key3.weight = 1
    key3.alignMiddle()
    keyView.appendView(key3)
    key3.fillVertical()

    //  Buttons for definition and settings
    appendView(buttonView)
    buttonView.weight = 0
    let button1 = Button("Definition")
    button1.weight = 1
    buttonView.appendView(button1)
    button1.fillVertical()
    let button2 = Button("Settings")
    button2.weight = 1
    buttonView.appendView(button2)
    button2.fillVertical()
    buttonView.fillHorizontal()

    appendView(View())  //  or buttons don't show ?!?
  }

  func clearItems() {
    animlist.clear()
  }

  override func invalidate() {
    animlist.invalidate()
  }

  func addItem(_ item:AnimListItem, view v:View = View()) {
    v.weight = 1
    animlist.appendView(v)
    v.fillVertical()
    if (item.celltype == CellType.Separator) {
      v.height = 4
    }
    if (item.celltype == CellType.Header) {
      v.textColor = UIColor.white
    } else if (item.wasItemSelected) {
      v.textColor = UIColor.blue.darker(0.5)
    }
    if (item.celltype == CellType.Separator || item.celltype == CellType.Header) {
      v.backgroundColor = UIColor.SEPARATOR
    }
  }

}
