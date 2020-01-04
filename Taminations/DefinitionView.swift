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

class DefinitionView : LinearLayout {

  private let webView = WebView("")
  let buttonView = RadioGroup()
  let abbrevRB: RadioButton
  let fullRB: RadioButton

  init() {
    abbrevRB = buttonView.addButton("Abbreviated")
    fullRB = buttonView.addButton("Full")
    super.init(.VERTICAL)
    appendView(webView)
    webView.weight = 1
    webView.fillHorizontal()
    appendView(buttonView)
    buttonView.weight = 0
    buttonView.fillHorizontal()
    buttonView.backgroundColor = UIColor.FLOOR
  }

  func setSource(_ src:String, afterload: @escaping ()->() = { }) {
    webView.setSource(src,afterload:afterload)
  }

  func eval(_ script:String, _ code:@escaping (String)->() = { _ in }) {
    webView.eval(script,code)
  }

}
