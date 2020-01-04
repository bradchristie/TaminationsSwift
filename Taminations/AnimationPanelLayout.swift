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

class AnimationPanelLayout : LinearLayout {

  let rewindButton = ImageButton(StartShape())
  let backButton = ImageButton(BackwardShape())
  let playButton = ImageButton(PlayShape())
  let forwardButton = ImageButton(ForwardShape())
  let endButton = ImageButton(EndShape())
  let beatSlider = Slider()
  let ticView = SliderTicView()

  init() {
    super.init(.VERTICAL)
    appendView(beatSlider)
    beatSlider.weight = 0
    beatSlider.fillHorizontal()
    appendView(ticView)
    ticView.height = max(20,Application.screenHeight/40)
    ticView.weight = 0
    ticView.fillHorizontal()
    let panelButtons = LinearLayout(.HORIZONTAL)
    rewindButton.weight = 1
    backButton.weight = 1
    playButton.weight = 1
    forwardButton.weight = 1
    endButton.weight = 1
    panelButtons.appendView(rewindButton)
    rewindButton.fillVertical()
    panelButtons.appendView(backButton)
    backButton.fillVertical()
    panelButtons.appendView(playButton)
    playButton.fillVertical()
    panelButtons.appendView(forwardButton)
    forwardButton.fillVertical()
    panelButtons.appendView(endButton)
    endButton.fillVertical()
    appendView(panelButtons)
    panelButtons.fillHorizontal()
  }

}
