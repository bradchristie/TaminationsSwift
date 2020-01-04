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

class WithTheFlow : Action {

  override var level:LevelData { return LevelObject.find("c1") }

  init() {
    super.init("With the Flow")
  }

  override func performCall(_ ctx: CallContext, _ index: Int) throws {
    if (ctx.actives.any { d in
      !ctx.isInCouple(d)
    }) {
      throw CallError("Only couples can do With the Flow")
    }
    var isLeft = true
    var isRight = true
    ctx.actives.forEach { d in
      let roll = ctx.roll(d)
      if (!roll.isLeft) {
        isLeft = false
      }
      if (!roll.isRight) {
        isRight = false
      }
    }
    //  Rolling direction determines who walks and who dodges
    if (isRight) {
      try ctx.applyCalls("Beau Walk Belle Dodge")
    } else if (isLeft) {
      try ctx.applyCalls("Belle Walk Beau Dodge")
    } else {
      throw CallError("All dancers must be moving the same direction for With the Flow")
    }
  }

}
