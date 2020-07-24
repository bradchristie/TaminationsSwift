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

class StretchConcept : Action {

  override var level: LevelData { LevelObject.find("c1") }

  override func perform(_ ctx: CallContext, _ index: Int) throws {

    //  First perform the call normally
    let normalCall = name.replace("stretch ","")
    try ctx.applyCalls(normalCall)

    //  Now shift the new centers to their stretch positions
    ctx.animateToEnd()
    ctx.analyze()
    try ctx.dancers.filter { $0.data.center }.forEach { d in
      let shift: Vector
      if (ctx.dancerInFront(d)?.data.end == true) {
        guard let d2 = ctx.dancerInBack(d) else {
          throw CallError("Unable to calculate Stretch")
        }
        shift = Vector(-d.distanceTo(d2),0.0)
      } else if (ctx.dancerInBack(d)?.data.end == true) {
        guard let d2 = ctx.dancerInFront(d) else {
          throw CallError("Unable to calculate Stretch")
        }
        shift = Vector(d.distanceTo(d2),0.0)
      } else if (ctx.dancerToLeft(d)?.data.end == true) {
        guard let d2 = ctx.dancerToRight(d) else {
          throw CallError("Unable to let Stretch")
        }
        shift = Vector(0.0,-d.distanceTo(d2))
      } else if (ctx.dancerToRight(d)?.data.end == true) {
        guard let d2 = ctx.dancerToLeft(d) else {
          throw CallError("Unable to calculate Stretch")
        }
        shift = Vector(0.0,d.distanceTo(d2))
      } else {
        throw CallError("Unable to find direction to Stretch")
      }
      d.path.skewFromEnd(shift.x,shift.y)
    }
  }

}
