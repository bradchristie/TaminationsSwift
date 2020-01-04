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

class TutorialPage : Page {

  let _view = PracticeLayout()
  override var view:View { get { return _view } }
  private let model:TutorialModel
  override var orientation: UIInterfaceOrientationMask {
    return .landscape
  }

  override init() {
    model = TutorialModel(_view)
    super.init()
    let av = _view.animationView
    onAction(Request.Action.TUTORIAL) { _ in
      self.model.nextAnimation("")
    }
    onMessage(Request.Action.BUTTON_PRESS) { request in
      switch (request["button"]) {
        case "Repeat" :
          self._view.resultsPanel.hide()
          av.doPlay()
        case "Next" : 
          self.model.nextAnimation("Continue")
        case "Return" :
          Application.app.goBack()
        default : break
      }
    }
    onMessage(.ANIMATION_LOADED) { _ in
      self.model.animationReady()
    }
    onMessage(Request.Action.ANIMATION_DONE) { _ in
      self.model.animationDone()
    }
  }


}
