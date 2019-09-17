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

class Zoom : Action {

  override var level:LevelData { return LevelObject.find("b2") }

  init() {
    super.init("Zoom")
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {

    if (d.data.leader) {
      guard let d2 = ctx.dancerInBack(d) else {
        throw CallError("Dancer \(d) cannot Zoom")
      }
      let a = d.angleToOrigin
      let c = (a < 0) ? "Run Left" : "Run Right"
      if (!d2.data.active) {
        throw CallError("Trailer of dancer $d is not active")
      }
      let dist = d.distanceTo(d2)
      return TamUtils.getMove(c).changebeats(2.0).skew(-dist/2,0.0) +
             TamUtils.getMove(c).changebeats(2.0).skew(dist/2.0,0.0)

    } else if (d.data.trailer) {
      guard let d2 = ctx.dancerInFront(d) else {
        throw CallError("Dancer \(d) cannot Zoom")
      }
      if (!d2.data.active) {
        throw CallError("Leader of dancer \(d) is not active")
      }
      let dist = d.distanceTo(d2)
      return TamUtils.getMove("Forward").changebeats(4.0).scale(dist,1.0)

    } else {
      throw CallError("Dancer \(d) cannot Zoom")
    }
  }

}
