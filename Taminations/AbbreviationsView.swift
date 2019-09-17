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

class AbbreviationsView : ScrollingLinearLayout {

  struct AbbreviationItem {
    let abbr:String
    let expa:String
  }

  func addItem(_ abbrev:String="", _ expansion:String="") {
    let line = LinearLayout(.HORIZONTAL)
    line.weight = 0
    let abbrText = TextInput()
    abbrText.backgroundColor = UIColor.white
    abbrText.text = abbrev
    abbrText.weight = 1
    abbrText.returnAction {
      Application.app.sendMessage(.ABBREVIATIONS_CHANGED)
    }
    abbrText.fillVertical()
    abbrText.focus()
    line.appendView(abbrText)
    let expaText = TextInput()
    expaText.backgroundColor = UIColor.white
    expaText.text = expansion
    expaText.weight = 4
    expaText.returnAction {
      Application.app.sendMessage(.ABBREVIATIONS_CHANGED)
    }
    expaText.fillVertical()
    line.appendView(expaText)
    line.fillHorizontal()
    appendView(line)
  }

  var numItems:Int { return items.count }

  private func abbrView(_ i:Int) -> TextInput {
    return (items[i] as! ViewGroup).children[0] as! TextInput
  }
  private func expaView(_ i:Int) -> TextInput {
    return (items[i] as! ViewGroup).children[1] as! TextInput
  }

  subscript(index: Int) -> AbbreviationItem {
    return AbbreviationItem(abbr: abbrView(index).text, expa: expaView(index).text)
  }

  func clearErrors() {
    items.forEach { child in
      (child as! ViewGroup).children[0].backgroundColor = UIColor.white
    }
  }

  func markError(_ i:Int) {
    abbrView(i).backgroundColor = UIColor.red
  }

}