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

class SequencerLayout : LinearLayout {

  let animationView = AnimationView()
  let panelLayout = AnimationPanelLayout()
  let beatText = TextView("beats")
  let callText = TextView("")
  private let abbrButton = Button("Abbrev")
  private let instructionsButton = Button("Help")
  private let settingsButton = Button("Settings")
  private let callsButton = Button("Calls")
  private let undoButton = Button("Undo")
  private let resetButton = Button("Reset")
  private let copyButton = Button("Copy")
  private let pasteButton = Button("Paste")
  let editButtons = LinearLayout(Direction.HORIZONTAL)
  let pageButtons = LinearLayout(Direction.HORIZONTAL)

  init() {
    super.init(.VERTICAL)
    backgroundColor = UIColor.black
    let rel = RelativeLayout()
    rel.weight = 1
    rel.appendView(animationView)
    rel.appendView(beatText)
    beatText.margins = 10
    beatText.textSize = 24
    beatText.height = 30
    beatText.width = 200
    beatText.alignBottom().alignRight()
    rel.appendView(callText)
    rel.appendView(callText)
    callText.margins = 10
    callText.textSize = 32
    callText.height = 48
    callText.alignLeft()
    callText.alignTop()
    animationView.fillParent()
    appendView(rel)
    rel.fillHorizontal()

    appendView(panelLayout).weight(0).fillHorizontal()

    appendView(editButtons)
    editButtons.weight = 0
    undoButton.weight = 1
    resetButton.weight = 1
    copyButton.weight = 1
    pasteButton.weight = 1
    editButtons.fillHorizontal()
    editButtons.appendView(undoButton)
    undoButton.fillVertical()
    editButtons.appendView(resetButton)
    resetButton.fillVertical()
    editButtons.appendView(copyButton)
    copyButton.fillVertical()
    editButtons.appendView(pasteButton)
    pasteButton.fillVertical()

    pageButtons.weight = 0
    instructionsButton.weight = 1
    settingsButton.weight = 1
    abbrButton.weight = 1
    callsButton.weight = 1
    pageButtons.appendView(instructionsButton)
    instructionsButton.fillVertical()
    pageButtons.appendView(settingsButton)
    settingsButton.fillVertical()
    pageButtons.appendView(abbrButton)
    abbrButton.fillVertical()
 //   pageButtons.appendView(callsButton)
    callsButton.fillVertical()
    appendView(pageButtons)
    pageButtons.fillHorizontal()
  }

  override func layoutChildren() {
    beatText.height = 30
    beatText.width = 200
    callText.height = 48
    callText.fillHorizontal()
    super.layoutChildren()
  }
}
