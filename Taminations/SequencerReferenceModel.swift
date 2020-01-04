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

class SequencerReferenceModel {

  private let view:SequencerReferenceView

  init(_ view:SequencerReferenceView) {
    self.view = view
  }

  func reset() {
    view.calllist.clearItems()
    let boxes = [view.b1Checkbox,view.b2Checkbox,view.msCheckbox,
                 view.plusCheckbox,view.a1Checkbox,view.a2Checkbox]
    let levels = ["b1","b2","ms","plus","a1","a2"]
    let selectors = [0,1,2,3,4,5]
      .filter { (boxes[$0] as CheckBox).isChecked }
      .map { LevelObject.find(levels[$0]).selector }
      .joined(separator: " | ")
    if (!selectors.isBlank) {
      let list = TamUtils.calldoc.xpath(selectors).sorted
            { (x1,x2) in x1.attr("title")! < x2.attr("title")! }
      list.forEach { it in
        view.calllist.addItem(CallListData(
          title: it.attr("title")!, 
          link: it.attr("link")!))
      }
    }
    view.calllist.invalidate()
  }

}
