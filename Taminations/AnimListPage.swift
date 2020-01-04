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

class AnimListPage : Page {

  private let _view = AnimListView()
  override var view:View { get { return _view } }
  var animListModel: AnimListModel?

  override init() {
    super.init()
    onAction(.ANIMLIST) { request in
      self._view.clearItems()
      if (Application.isPortrait) {
        self._view.buttonView.show()
      } else {
        self._view.buttonView.hide()
      }
      self.animListModel = AnimListModel(self._view,request)
    }
    onMessage(.ANIMATION) { request in
      if (Application.isPortrait) {
        Application.app.sendRequest(request)
      }
    }
    onMessage(.REGENERATE) { _ in
      if let link = self.animListModel?.link {
        self._view.clearItems()
        self.animListModel = AnimListModel(self._view,
          Request(.ANIMLIST,("link",link)))
      }
    }
    onMessage(.BUTTON_PRESS) { request in
      if (Application.isPortrait) {
        if (request["button"] == "Settings") {
          Application.app.sendRequest(.SETTINGS)
        }
        if (request["button"] == "Definition") {
          Application.app.sendRequest(.DEFINITION,("link",self.animListModel!.link))
        }
      }
    }
  }

}