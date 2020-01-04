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

class SecondLandscapePage : Page {

  let _view = LinearLayout(.HORIZONTAL)
  override var view:View { get { return _view } }
  private let leftPage = AnimListPage()
  private let centerPage = AnimationPage()
  private let rightPage = NavigationPage()

  override init() {
    super.init()
    view.backgroundColor = UIColor.lightGray
    rightPage.pages = [DefinitionPage(), SettingsPage()]
    _view.appendView(leftPage.view)
    _view.appendView(centerPage.view)
    _view.appendView(rightPage.view)
    leftPage.view.weight = 1
    centerPage.view.weight = 1
    rightPage.view.weight = 1
    leftPage.view.fillVertical()
    centerPage.view.fillVertical()
    rightPage.view.fillVertical()

    onMessage(.ANIMATION_READY) { request in
      //  The list of animations is complete
      //  Choose either an animation in the link
      //  or if none the first animation
  //  TODO  if (!leftPage.animListModel.selectAnimationByName(request["name"])) {
        self.leftPage.animListModel!.selectFirstAnimation()
  //    }
      //  Send request to navigation page so it brings up the definition
      self.rightPage.doRequest(.DEFINITION, request)
    }
    onMessage(.ANIMATION) { request in
      //  Animate a change to a different Tamination
      Page.animate(self.centerPage, self.centerPage) {
        self.centerPage.doRequest(.ANIMATION, request)
      }
    }
    onMessage(.BUTTON_PRESS) { request in
      if (request["button"] == "Settings") {
        self.rightPage.doRequest(.SETTINGS)
      } else if (request["button"] == "Definition") {
        self.rightPage.doRequest(.DEFINITION, ("link", self.leftPage.animListModel!.link))
      }
    }
  }

  override func doRequest(_ request: Request) -> Bool {
    if (request.action == .ANIMLIST || request.action == .ANIMATION) {
      leftPage.doRequest(.ANIMLIST,request)
      return true
    }
    return false
  }

  override func canDoAction(_ action: Request.Action) -> Bool {
    return leftPage.canDoAction(action)
  }

  override func sendMessage(_ message: Request) {
    super.sendMessage(message)
    leftPage.sendMessage(message)
    centerPage.sendMessage(message)
    rightPage.sendMessage(message)
  }

}
