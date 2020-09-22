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

//  This class implements both Zoom and Zing
class Zoom : Action {

  override var level: LevelData {
    LevelObject.find(norm == "zing" ? "c1" : "b2")
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {

    let a = d.angleToOrigin
    let centerLeft = ctx.dancersToRight(d).count == 2 &&
      ctx.dancersToLeft(d).count == 1
    let centerRight = ctx.dancersToRight(d).count == 1 &&
      ctx.dancersToLeft(d).count == 2
    let (c, c2, c3) =
      centerLeft ? ("Run Right", "Lead Right", "Quarter Left") :
        centerRight ? ("Run Left", "Lead Left", "Quarter Right") :
        a < 0 ? ("Run Left", "Lead Left", "Quarter Right") :
        ("Run Right", "Lead Right", "Quarter Left")
    let s = (centerLeft || centerRight) ? 0.25 : 1.0

    if (d.data.leader) {
      guard let d2 = ctx.dancerInBack(d) else {
        throw CallError("Dancer \(d) cannot \(name)")
      }
      if (!d2.data.active) {
        throw CallError("Trailer of dancer \(d) is not active.")
      }
      let dist = d.distanceTo(d2)
      return TamUtils.getMove(c).changebeats(2.0).skew(-dist / 2.0, 0.0).scale(1.0, s) +
        (norm == "zoom" ? TamUtils.getMove(c).changebeats(2.0).skew(dist / 2.0, 0.0).scale(1.0, s)
                        : TamUtils.getMove(c2).changebeats(2.0).scale(dist / 2.0, 2.0 * s))

    } else if (d.data.trailer) {
      guard let d2 = ctx.dancerInFront(d) else {
        throw CallError("Dancer \(d) cannot \(name)")
      }
      if (!d2.data.active) {
        throw CallError("Leader of dancer \(d) is not active.")
      }
      let dist = d.distanceTo(d2)
      return norm == "zoom"
        ? TamUtils.getMove("Forward").changebeats(4.0).scale(dist, 1.0)
        : TamUtils.getMove("Forward").changebeats(2.0).scale(dist - 1.0, 1.0) +
          TamUtils.getMove(c3).changebeats(2.0).skew(1.0, 0.0)

    } else {
      throw CallError("Dancer \(d) cannot \(name)")
    }
  }
}
