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

class AnimationPage : Page {

  private let _view = AnimationLayout()
  override var view:View { get { return _view } }
  private var model:AnimationModel?
  private var panelmodel:AnimationPanelModel?
  private var animnum = -1

  override init() {
    super.init()
    let av = _view.animationView
    let ap = _view.panellayout
    var saveRequest = Request(.ANIMATION)
    onAction(.ANIMATION) { request in
      saveRequest = request
      self.animnum = request["animnum"]?.i ?? -1
      self.model = AnimationModel(self._view, request["link"]!,anim: self.animnum)
      self.panelmodel = AnimationPanelModel(self._view.panellayout,
        self._view.animationView)
    }
    onMessage(.ANIMATION_LOADED) { message in
      self._view.panellayout.ticView.setTics(av.totalBeats, partstr:av.partsstr, isParts: av.hasParts)
      av.readAnimationSettings()
      self._view.itemText.text = "\(self.animnum+1) of \(self.model!.tamcount)"
    }
    onMessage(.SETTINGS_CHANGED) { message in
      av.readAnimationSettings()
    }
    onMessage(.ANIMATION_PROGRESS) { message in
      let beat = message["beat"]!.d
      ap.beatSlider.setValue(beat * 100 / av.totalBeats)
      let alpha = max((2.0-beat) / 2.01, 0.0)
      self._view.saysText.opacity = alpha
    }
    onMessage(.ANIMATION_DONE) { message in
      ap.playButton.setImage(PlayShape())
    }
    onMessage(.BUTTON_PRESS) { request in
      if (Application.isPortrait) {
        if (request["button"] == "Settings") {
          Application.app.sendRequest(.SETTINGS)
        }
        if (request["button"] == "Definition") {
          Application.app.sendRequest(.DEFINITION,("link",self.model!.link))
        }
      }
    }
    //  In portrait, swipe to switch animations
    if (Application.isPortrait) {
      _view.swipeAction { dir in
        if (dir == .LEFT && self.animnum < self.model!.tamcount-1) {
          saveRequest["animnum"] = (self.animnum+1).s
          Application.app.sendRequest(saveRequest)
        } else if (dir == .RIGHT && self.animnum > 0) {
          saveRequest["animnum"] = (self.animnum-1).s
          Application.app.sendRequest(saveRequest)
        }
      }
    }
  }

}
