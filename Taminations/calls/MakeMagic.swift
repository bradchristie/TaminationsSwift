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

class MakeMagic : Action {

  init() {
    super.init("Make Magic")
  }

  override var level: LevelData {
    return LevelObject.find("c1")
  }
  override var requires: [String] {
    return ["a1/cross_trail_thru"]
  }

  override func performCall(_ ctx: CallContext, _ index: Int) throws {
    //  If center 4 dancers are facing each other, they do a Cross Trail Thru
    if (ctx.center(4).all { d in d.isFacingIn } ) {
      try ctx.applyCalls("Center 4 Cross Trail Thru")
    } else {
      //  Otherwise, process each dancer
      try super.performCall(ctx, index)
      if (ctx.dancers.all { d in d.path.movelist.isEmpty } ) {
        throw CallError("Make Magic does nothing")
      }
    }
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    //  Center and outside dancers facing each other pass thru
    if let d2 = ctx.dancerFacing(d) {
      if (ctx.center(4).contains(d) ^ ctx.center(4).contains(d2)) {
        let dist = d.distanceTo(d2)
        return TamUtils.getMove("Extend Left").scale(dist / 2, 0.5) +
          TamUtils.getMove("Extend Right").scale(dist / 2, 0.5)
      }
    }
    //  Center dancers facing in cross
    if (ctx.center(4).contains(d) && d.isFacingIn) {
      //  Compute the X and Y values to travel
      //  The standard has x distance = 2 and y distance = 2
      let a = d.angleToOrigin
      let dx = d.location.length * a.Cos
      let dy = d.location.length * a.abs.Sin
      return TamUtils.getMove((a > 0) ? "Cross Left" : "Cross Right").scale(dx, dy)
    }
    return Path()
  }

}
