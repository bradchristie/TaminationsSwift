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

class AnimationPanelModel {

  init(_ ap:AnimationPanelLayout, _ av:AnimationView) {
    ap.playButton.clickAction {
      if (av.isRunning) {
        av.doPause()
        ap.playButton.setImage(PlayShape())
      } else {
        av.doPlay()
        ap.playButton.setImage(PauseShape())
      }
    }
    ap.rewindButton.clickAction {
      av.doPrevPart()
    }
    ap.backButton.clickAction {
      av.doBackup()
    }
    ap.forwardButton.clickAction {
      av.doForward()
    }
    ap.endButton.clickAction {
      av.doNextPart()
    }
    ap.beatSlider.slideAction { value in
      av.setTime(value * av.totalBeats / 100.0)
    }

  }

}
