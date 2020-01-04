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

class FirstLandscapePage : Page {

  let _view = LinearLayout(.HORIZONTAL)
  override var view:View { get { return _view } }
  private let leftPage = LevelPage()
  private let rightPage = NavigationPage()

  override init() {
    super.init()
    rightPage.pages = [AboutPage(), CallListPage(), SettingsPage()]
    leftPage.view.weight = 3
    leftPage.view.fillVertical()
    rightPage.view.weight = 6
    rightPage.view.fillVertical()
    _view.appendView(leftPage.view)
    _view.appendView(rightPage.view)
  }

  override func doRequest(_ request: Request) -> Bool {
    let retval = leftPage.doRequest(request) || rightPage.doRequest(request)
    if (retval) {
      Application.app.titleBar.level = ""
    }
    return retval
  }

  override func canDoAction(_ action: Request.Action) -> Bool {
    return leftPage.canDoAction(action) ||
      rightPage.canDoAction(action) ||
      (Application.isLandscape && action == .STARTUP)
  }

  override func sendMessage(_ message: Request) {
    leftPage.sendMessage(message)
    rightPage.sendMessage(message)
  }


}
