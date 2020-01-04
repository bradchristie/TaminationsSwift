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

class RadioGroup : View {

  let mydiv = UISegmentedControl()
  private var buttons:[RadioButton] = []

  init() {
    super.init(mydiv)
    mydiv.translatesAutoresizingMaskIntoConstraints = false
    mydiv.addTarget(self, action: #selector(RadioGroup.onClick), for: .valueChanged)
    mydiv.tintColor = UIColor.green.darker(0.5)
  }

  func addButton(_ text:String) -> RadioButton {
    mydiv.insertSegment(withTitle: text, at: buttons.count, animated: false)
    let button = RadioButton(self,buttons.count)
    buttons.append(button)
    return button
  }

  @objc func onClick() {
    buttons[mydiv.selectedSegmentIndex].clickCode()
  }

}

class RadioButton {

  private let group:RadioGroup
  private let index:Int
  var clickCode:()->() = { }

  init(_ group:RadioGroup, _ index:Int) {
    self.group = group
    self.index = index
  }

  var isChecked:Bool {
    get {
      return group.mydiv.selectedSegmentIndex == index
    }
    set {
      if (newValue) {
        group.mydiv.selectedSegmentIndex = index
      }
    }
  }

  func clickAction(_ code: @escaping ()->()) {
    clickCode = code
  }

}