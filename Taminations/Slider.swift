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

class Slider : View {

  private let mydiv = UISlider()
  private var slideCode:(Double)->() = { _ in }

  init() {
    super.init(mydiv)
    mydiv.translatesAutoresizingMaskIntoConstraints = false
    mydiv.minimumValue = 0.0
    mydiv.maximumValue = 100.0
    mydiv.addTarget(self, action:#selector(Slider.sliderSelector), for:.valueChanged)
  }

  //  User has moved the slider
  @objc func sliderSelector() {
    slideCode(mydiv.value.d)
  }

  //  Set action for when user moves slider
  func slideAction(code: @escaping (Double)->()) {
    slideCode = code
  }

  //  Application is changing the value
  func setValue(_ v:Double) {
    mydiv.value = v.f
  }

}
