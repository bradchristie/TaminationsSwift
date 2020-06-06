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

class DropDown {

  private var vc = UIViewController()
  private var selectCode:(String)->() = { _ in }
  private var view = LinearLayout(.VERTICAL)

  init() {
    vc.modalPresentationStyle = .popover
    vc.view = view.div
    view.fillHorizontal()
  }

  func showAt(_ v:View, _ x:Int, _ y:Int) {
    let popover = vc.popoverPresentationController!
    popover.sourceView = v.div
    popover.sourceRect = CGRect(x: x.cg, y: y.cg, width: 0, height: 0)
    Application.viewController.present(vc, animated: true)
  }

  func selectAction(code: @escaping (String)->()) {
    selectCode = code
  }

  @discardableResult
  func addItem(_ name:String, _ f:(View) -> () = { _ in } ) -> View {
    let item = SelectablePanel()
    item.weight = 1
    item.fillHorizontal()
    let text = TextView(name)
    text.leftMargin = 20
    text.fillParent()
    item.appendView(text)
    item.clickAction {
      self.selectCode(name)
    }
    view.appendView(item)
    f(item)
    return item
  }

  func hide() {
    vc.dismiss(animated: true)
  }


}
