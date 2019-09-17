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

class StartPracticeLayout : LinearLayout {

  init() {
    super.init(.HORIZONTAL)
    backgroundColor = UIColor.FLOOR
    //  left side - options
    let leftSide = LinearLayout(.VERTICAL)
    leftSide.weight = 1
    leftSide.backgroundColor = UIColor.FLOOR
    leftSide.leftMargin = 10
    let firstLine = TextView("Choose a Gender")
    firstLine.alignLeft()
    firstLine.fillHorizontal()
    firstLine.textSize = 36.pp
    leftSide.appendView(firstLine)
    let secondLine = LinearLayout(.HORIZONTAL)
    secondLine.fillHorizontal()
    let secondGroup = RadioGroup()
    secondGroup.alignLeft()
    secondGroup.fillVertical()
    let boyButton = secondGroup.addButton("Boy")
    boyButton.isChecked = Setting("PracticeGender").s == "Boy"
    boyButton.clickAction { Setting("PracticeGender").s = "Boy" }
    let girlButton = secondGroup.addButton("Girl")
    girlButton.isChecked = Setting("PracticeGender").s != "Boy"
    girlButton.clickAction { Setting("PracticeGender").s = "Girl" }
    secondLine.appendView(secondGroup)
    let secondFill = View()
    secondFill.weight = 1
    secondLine.appendView(secondFill)
    leftSide.appendView(secondLine)
    let thirdLine = TextView("Speed for Practice")
    thirdLine.textSize = 36.pp
    thirdLine.topMargin = 20
    thirdLine.alignLeft()
    thirdLine.fillHorizontal()
    leftSide.appendView(thirdLine)
    let fourthLine = LinearLayout(.HORIZONTAL)
    let fourthGroup = RadioGroup()
    fourthGroup.alignLeft()
    fourthGroup.fillVertical()
    let slowButton = fourthGroup.addButton("Slow")
    slowButton.isChecked = Setting("PracticeSpeed").s == "Slow"
    slowButton.clickAction { Setting("PracticeSpeed").s = "Slow" }
    let moderateButton = fourthGroup.addButton("Moderate")
    moderateButton.isChecked = Setting("PracticeSpeed").s != "Slow" && Setting("PracticeSpeed").s != "Normal"
    moderateButton.clickAction { Setting("PracticeSpeed").s = "Moderate" }
    let normalButton = fourthGroup.addButton("Normal")
    normalButton.isChecked = Setting("PracticeSpeed").s == "Normal"
    normalButton.clickAction { Setting("PracticeSpeed").s = "Normal" }
    fourthLine.appendView(fourthGroup)
    let fourthFill = View()
    fourthFill.weight = 1
    fourthLine.appendView(fourthFill)
    fourthLine.fillHorizontal()
    leftSide.appendView(fourthLine)
    let fifthLine = TextView("Primary Control")
    fifthLine.textSize = 36.pp
    fifthLine.topMargin = 20
    fifthLine.alignLeft()
    fifthLine.fillHorizontal()
    leftSide.appendView(fifthLine)
    let sixthLine = LinearLayout(.HORIZONTAL)
    let sixthGroup = RadioGroup()
    sixthGroup.alignLeft()
    sixthGroup.fillVertical()
    let rightButton = sixthGroup.addButton("Right Finger")
    rightButton.isChecked = Setting("PrimaryControl").s != "Left"
    rightButton.clickAction { Setting("PrimaryControl").s = "Right" }
    let leftButton = sixthGroup.addButton("Left Finger")
    leftButton.isChecked = Setting("PrimaryControl").s == "Left"
    leftButton.clickAction { Setting("PrimaryControl").s = "Left" }
    sixthLine.appendView(sixthGroup)
    let sixthFill = View()
    sixthFill.weight = 1
    sixthLine.appendView(sixthFill)
    sixthLine.fillHorizontal()
    leftSide.appendView(sixthLine)

    //  right side - levels and tutorial
    let rightSide = LinearLayout(.VERTICAL)
    rightSide.weight = 1
    let firstRow = startPracticeLevel("Tutorial")
    rightSide.appendView(firstRow)
    firstRow.fillHorizontal()
    let secondRow = LinearLayout(.HORIZONTAL)
    secondRow.weight = 1
    let secondRowItem1 = startPracticeLevel("Basic 1")
    secondRow.appendView(secondRowItem1)
    secondRowItem1.fillVertical()
    let secondRowItem2 = startPracticeLevel("Basic 2")
    secondRow.appendView(secondRowItem2)
    secondRowItem2.fillVertical()
    rightSide.appendView(secondRow)
    secondRow.fillHorizontal()
    let thirdRow = LinearLayout(.HORIZONTAL)
    thirdRow.weight = 1
    let thirdRowItem1 = startPracticeLevel("Mainstream")
    thirdRow.appendView(thirdRowItem1)
    thirdRowItem1.fillVertical()
    let thirdRowItem2 = startPracticeLevel("Plus")
    thirdRow.appendView(thirdRowItem2)
    thirdRowItem2.fillVertical()
    rightSide.appendView(thirdRow)
    thirdRow.fillHorizontal()
    let fourthRow = LinearLayout(.HORIZONTAL)
    fourthRow.weight = 1
    let fourthRowItem1 = startPracticeLevel("A-1")
    fourthRow.appendView(fourthRowItem1)
    fourthRowItem1.fillVertical()
    let fourthRowItem2 = startPracticeLevel("A-2")
    fourthRow.appendView(fourthRowItem2)
    fourthRowItem2.fillVertical()
    rightSide.appendView(fourthRow)
    fourthRow.fillHorizontal()
    let fifthRow = LinearLayout(.HORIZONTAL)
    fifthRow.weight = 1
    let fifthRowItem1 = startPracticeLevel("C-1")
    fifthRow.appendView(fifthRowItem1)
    fifthRowItem1.fillVertical()
    let fifthRowItem2 = startPracticeLevel("C-2")
    fifthRow.appendView(fifthRowItem2)
    fifthRowItem2.fillVertical()
    rightSide.appendView(fifthRow)
    fifthRow.fillHorizontal()
    let sixthRow = LinearLayout(.HORIZONTAL)
    sixthRow.weight = 1
    let sixthRowItem1 = startPracticeLevel("C-3A")
    sixthRow.appendView(sixthRowItem1)
    sixthRowItem1.fillVertical()
    let sixthRowItem2 = startPracticeLevel("C-3B")
    sixthRow.appendView(sixthRowItem2)
    sixthRowItem2.fillVertical()
    rightSide.appendView(sixthRow)
    sixthRow.fillHorizontal()

    appendView(leftSide)
    appendView(rightSide)
    leftSide.alignTop()
    rightSide.fillVertical()

  }


  func startPracticeLevel(_ level:String) -> SelectablePanel {
    let panel = SelectablePanel()
    panel.weight = 1
    if (level == "Tutorial") {
      panel.backgroundColor = UIColor.lightGray.brighter()
      panel.clickAction {
        Application.app.sendRequest(.TUTORIAL)
      }
    } else {
      panel.backgroundColor = LevelObject.find(level).color
      panel.clickAction {
        Application.app.sendRequest(.PRACTICE,("level",level))
      }
    }
    let label = TextView(level)
    label.fillHorizontal()
    label.alignMiddle().alignCenter()
    label.textSize = 25.pp
    label.textStyle = "bold"
    label.bottomBorder = 1
    label.leftBorder = 1
    label.weight = 1
    panel.appendView(label)
    label.fillVertical()
    return panel
  }



}
