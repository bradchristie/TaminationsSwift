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

class AboutPage : Page {

  private let _view = WebView("info/about")
  override var view:View { get { return _view } }

  //  Note that showing the About page is the default
  //  if nothing is specified (i.e. startup)
  override func doRequest(_ request: Request) -> Bool {
    if (request.action == .ABOUT ||
      (Application.isLandscape && request.action == .STARTUP)) {
      Application.app.titleBar.title = "Taminations"
      return true
    }
    return false
  }

  override func canDoAction(_ action: Request.Action) -> Bool {
    return action == .ABOUT ||
      (Application.isLandscape && action == .STARTUP)
  }
}
