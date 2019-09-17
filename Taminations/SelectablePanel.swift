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

class SelectablePanel : LinearLayout {

  private class SelectableView : LinearLayoutView {
    private var selectCode:()->() = { }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      selectCode()
    }
    func selectAction(code: @escaping ()->()) {
      selectCode = code
    }
  }

  private var mydiv = SelectableView(.HORIZONTAL)
  var isSelected = false

  init() {
    super.init(mydiv)
    mydiv.selectAction {
      self.clickCode()
    }
  }

}
