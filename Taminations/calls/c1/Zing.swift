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

class Zing : Action {

  override var level:LevelData { LevelObject.find("c1") }

  init() {
    super.init("Zoom")
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    let a = d.angleToOrigin
    let c1 = a < 0 ? "Run Left" : "Run Right"
    let c2 = a < 0 ? "Lead Left" : "Lead Right"
    let c3 = a < 0 ? "Quarter Right" : "Quarter Left"
    if (d.data.leader) {
      guard let d2 = ctx.dancerInBack(d) else {
        throw CallError("Dancer \(d) cannot Zing")
      }
      if (!d2.data.active) {
        throw CallError("Trailer of dancer $d is not active")
      }
      let dist = d.distanceTo(d2)
      return TamUtils.getMove(c1).changebeats(2.0).skew(-dist/2,0.0) +
             TamUtils.getMove(c2).changebeats(2.0).scale(dist/2.0,2.0)

    } else if (d.data.trailer) {
      guard let d2 = ctx.dancerInFront(d) else {
        throw CallError("Dancer \(d) cannot Zing")
      }
      if (!d2.data.active) {
        throw CallError("Leader of dancer \(d) is not active")
      }
      let dist = d.distanceTo(d2)
      return TamUtils.getMove("Forward").changebeats(2.0).scale(dist-1,1.0) +
            TamUtils.getMove(c3).changebeats(2.0).skew(1.0,0.0)
    } else {
      throw CallError("Dancer \(d) cannot Zing")
    }
  }

}
