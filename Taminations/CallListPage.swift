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

class CallListPage : Page {

  private var _view = CallListView()
  private var model:CallListModel
  override var view:View { get { return _view } }
  var level = ""

  override init() {
    model = CallListModel(_view)
    super.init()
    onAction(Request.Action.CALLLIST) { request in
      self.level = request["level"] ?? ""
      Page.animate(self,self) {
        self.model.reset(self.level)
      }
      Application.app.titleBar.title = LevelObject.find(self.level).name
      Application.app.titleBar.level = " "
    }
    onMessage(Request.Action.CALLITEM) { request in
      Application.app.sendRequest(Request.Action.ANIMLIST, ("link",request["link"]!))
    }
    onMessage(.REGENERATE) { _ in
      self.model.reset(self.level, search: self._view.searchInput.text)
    }
  }

}
