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

class AnimationLayout : LinearLayout {

  let animationView = AnimationView()
  let panellayout = AnimationPanelLayout()
  let saysText = TextView("")
  let itemText = TextView("0 of 0")
  private let defintionButton = Button("Definition")
  private let settingsButton = Button("Settings")
  let buttonLayout = LinearLayout(.HORIZONTAL)

  init() {
    super.init(.VERTICAL)
    backgroundColor = UIColor.black
    let rel = RelativeLayout()
    rel.weight = 1
    rel.appendView(animationView)
    rel.appendView(saysText)
    saysText.alignTop()
    saysText.fillHorizontal()
    saysText.backgroundColor = UIColor.white
    saysText.topMargin = 6
    saysText.rightMargin = 6
    saysText.wrap()
    rel.appendView(itemText)
    itemText.alignBottom().alignRight()
    animationView.fillParent()
    panellayout.weight = 0
    buttonLayout.weight = 0
    appendView(rel)
    rel.fillHorizontal()
    appendView(panellayout)
    panellayout.fillHorizontal()
    settingsButton.weight = 1
    defintionButton.weight = 1
    buttonLayout.appendView(defintionButton)
    defintionButton.fillVertical()
    buttonLayout.appendView(settingsButton)
    settingsButton.fillVertical()
    appendView(buttonLayout)
    buttonLayout.fillHorizontal()
  }
}
