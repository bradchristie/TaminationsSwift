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

class SequencerReferenceView : LinearLayout {

  let b1Checkbox = CheckBox()
  let b2Checkbox = CheckBox()
  let msCheckbox = CheckBox()
  let plusCheckbox = CheckBox()
  let a1Checkbox = CheckBox()
  let a2Checkbox = CheckBox()
  let calllist = CallListView()

  func appendCheckBox(_ view:ViewGroup, _ box:CheckBox,_ text:String) {
    let lev = LevelObject.find(text)
    let panel = LinearLayout(.HORIZONTAL)
    panel.backgroundColor = lev.color
    panel.bottomBorder = 1
    panel.rightBorder = 1
    panel.weight = 1
    panel.appendView(box)
    panel.appendView(TextView(text))
    panel.fillVertical()
    view.appendView(panel)
  }

  init() {
    super.init(.VERTICAL)
    backgroundColor = UIColor.lightGray
    let line1 = LinearLayout(.HORIZONTAL)
    appendCheckBox(line1, b1Checkbox, "Basic 1")
    appendCheckBox(line1, msCheckbox, "Mainstream")
    appendCheckBox(line1, a1Checkbox, "A-1")
    let line2 = LinearLayout(.HORIZONTAL)
    appendCheckBox(line2, b2Checkbox, "Basic 2")
    appendCheckBox(line2, plusCheckbox, "Plus")
    appendCheckBox(line2, a2Checkbox, "A-2")
    line1.weight = 0
    line1.fillHorizontal()
    appendView(line1)
    line2.weight = 0
    line2.fillHorizontal()
    appendView(line2)
    calllist.weight = 1
    calllist.fillHorizontal()
    appendView(calllist)
    //  TODO calllist.searchinput.hide()
  }

}
