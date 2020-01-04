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

class AceyDeucey : Action {

  override var level:LevelData { return LevelObject.find("plus") }
  override var requires:[String] { return ["b2/trade","b1/circulate"] }

  init() {
    super.init("Acey Deucey")
  }

  override func performCall(_ ctx: CallContext, _ index: Int) throws {
    try ctx.applyCalls("Center 4 Trade While Outer 4 Circulate")
  }
}
