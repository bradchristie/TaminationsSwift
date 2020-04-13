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

class SweepAQuarter : Action {

  override var level:LevelData { LevelObject.find("b2") }
  override var requires:[String] { ["b2/sweep_a_quarter"] }

  init() {
    super.init("and Sweep a Quarter")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    if (ctx.actives.any { d in
      !ctx.isInCouple(d)
    }) {
      throw CallError("Only couples can Sweep a Quarter")
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
    //  Sweeping direction is opposite rolling direction
    if (isRight) {
      try ctx.applyCalls("Sweep a Quarter Left")
    } else if (isLeft) {
      try ctx.applyCalls("Sweep a Quarter Right")
    } else {
      throw CallError("All dancers must be moving the same direction to Sweep a Quarter")
    }
  }

}
