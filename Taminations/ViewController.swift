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

class ViewController: UIViewController {

  let app = Application()
  var layout:LinearLayout?

  override func loadView() {
    TamUtils.readinitfiles()
    if (!Application.istablet) {
      AppDelegate.AppUtility.setOrientation(.portrait)
    }
    layout = app.buildDisplay() as? LinearLayout
    view = layout!.div
    app.doRequest(Request(Request.Action.STARTUP))
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    //  Add hooks for when soft keyboard is displayed
    NotificationCenter.default.addObserver(self,
      selector: #selector(ViewController.keyboardDidShow),
      name:UIResponder.keyboardDidShowNotification, object: nil);
    NotificationCenter.default.addObserver(self,
      selector: #selector(ViewController.keyboardDidHide),
      name:UIResponder.keyboardDidHideNotification, object: nil);
  }


  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    Application.later {
      self.app.buildDisplay()
      Application.app.goHere()
    }
  }

  @objc func keyboardDidShow(sender: NSNotification) {
    //  Adjust display by setting height of dummy
    //  view to match keyboard
    if let f = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      Application.app.keyboardAdjustmentView.height = f.size.height.i
      Application.app.contentPage!.view.weight = 5  // hack to keep title bar about the same size
      layout?.layoutChildren()
      Application.app.sendMessage(Request(.REGENERATE))
    }
  }

  @objc func keyboardDidHide(sender: NSNotification) {
    Application.app.keyboardAdjustmentView.height = 0
    Application.app.contentPage!.view.weight = 9
    self.layout?.layoutChildren()
    Application.app.sendMessage(Request(.REGENERATE))
  }

}
