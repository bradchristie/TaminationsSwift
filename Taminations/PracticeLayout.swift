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

class PracticeLayout : LinearLayout {

  let animationView = AnimationView()
  let repeatButton = Button("Repeat")
  let continueButton = Button("Next")
  let returnButton = Button("Return")
  let definitionButton = Button("Definition")
  let resultsPanel = LinearLayout(.VERTICAL)
  let scoreNumbers = TextView("0 / 0")
  let scoreText = TextView("Poor")
  let definitionView = DefinitionView()

  init() {
    super.init(.HORIZONTAL)
    backgroundColor = UIColor.FLOOR
    animationView.fillVertical()
    animationView.weight = 2
    animationView.div.isMultipleTouchEnabled = true
    resultsPanel.width = Application.screenHeight * 2 / 3
    resultsPanel.topMargin = 20
    resultsPanel.leftMargin = 20
    //resultsPanel.fillVertical()
    resultsPanel.weight = 1
    let complete = TextView("Animation Complete")
    complete.alignMiddle()
    resultsPanel.appendView(complete)
    let yourscore = TextView("Your Score")
    yourscore.alignMiddle()
    resultsPanel.appendView(yourscore)
    scoreNumbers.alignMiddle()
    resultsPanel.appendView(scoreNumbers)
    scoreText.alignMiddle()
    resultsPanel.appendView(scoreText)
    let buttons1 = LinearLayout(.HORIZONTAL)
    buttons1.fillHorizontal()
    repeatButton.weight = 1
    continueButton.weight = 1
    returnButton.weight = 1
    repeatButton.fillVertical()
    continueButton.fillVertical()
    returnButton.fillVertical()
    buttons1.appendView(repeatButton)
    buttons1.appendView(continueButton)
    buttons1.appendView(returnButton)
    buttons1.appendView(View())  // hack to get Return button working
    resultsPanel.appendView(buttons1)
    let buttons2 = LinearLayout(.HORIZONTAL)
    definitionButton.fillVertical()
    buttons2.appendView(definitionButton)
    resultsPanel.appendView(buttons2)
    resultsPanel.children.forEach { it in
      it.alignLeft()
      if let t = it as? TextView {
        t.textSize = 32.pp
      }
      it.topMargin = 8
    }
    resultsPanel.alignTop()
    appendView(resultsPanel)
    appendView(animationView)
  }

}
