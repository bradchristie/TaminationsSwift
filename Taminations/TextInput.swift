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

class TextInput : View, UITextFieldDelegate {

  private let mydiv = UITextField()
  private var fontSize = 20
  private var onReturn = { }
  private var onKey = { }

  var text:String {
    get { return mydiv.text ?? "" }
    set { mydiv.text = newValue }
  }

  var textSize:Int {
    get { return fontSize }
    set {
      fontSize = newValue
      mydiv.font = UIFont(name:mydiv.font?.fontName ?? "Helvetica",size:fontSize.cg)
    }
  }

  var hint:String {
    get { return mydiv.placeholder ?? "" }
    set { mydiv.placeholder = newValue }
  }

  init() {
    super.init(mydiv)
    mydiv.translatesAutoresizingMaskIntoConstraints = false
    mydiv.autocapitalizationType = .none
    mydiv.autocorrectionType = .no
    mydiv.spellCheckingType = .no
    mydiv.clearButtonMode = .whileEditing
    mydiv.delegate = self
    backgroundColor = UIColor.white
    mydiv.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
  }

  func disable() {
    mydiv.isEnabled = false  // also hides the keyboard
  }
  func enable() {
    mydiv.isEnabled = true
  }

  func returnAction(_ code:@escaping ()->()) {
    onReturn = code
  }
  func keyAction(_ code:@escaping ()->()) {
    onKey = code
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    onReturn()
    return false
  }

  @objc func textFieldChanged() -> Bool {
    self.onKey()
    return true
  }

}
