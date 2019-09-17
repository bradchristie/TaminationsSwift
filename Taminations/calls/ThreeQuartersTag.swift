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

class ThreeQuartersTag : Action {

  override var level:LevelData { return LevelObject.find("ms") }
  override var requires:[String] { return ["ms/fraction_tag"] }

  init() {
    super.init("3/4 Tag the Line")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  All the 4-dancer formations are in Taminations
    if (ctx.actives.count < 8) {
      try ctx.applyCalls("3/4 Tag the Line")
    } else if (!ctx.isLines()) {
      throw CallError("Dancers must be in lines")
    } else {
      try super.perform(ctx, index)
    }
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    let dist = d.distanceTo(ctx.dancerInBack(d) ?? ctx.dancerInFront(d)!)/2.0
    let i = ctx.dancersToRight(d).count + (d.isFacingOut ? 4 : 0)
    switch (i) {
      case 0: return TamUtils.getMove("Quarter Left").skew(dist - 3, 1.0) +
        TamUtils.getMove("Forward 2")
      case 1: return TamUtils.getMove("Quarter Left").skew(dist - 2, 1.0) +
        TamUtils.getMove("Forward") +
        TamUtils.getMove("Extend Right").scale(2.0, 1.0).changebeats(2.0)
      case 2: return TamUtils.getMove("Lead Right").skew(dist - 2, 0.0) +
        TamUtils.getMove("Forward 3")
      case 3: return TamUtils.getMove("Lead Right").skew(dist - 2, 0.0) +
        TamUtils.getMove("Forward 2")
      case 4: return TamUtils.getMove("Quarter Left").skew(1 - dist, 1.0) +
        TamUtils.getMove("Forward 2")
      case 5: return TamUtils.getMove("Quarter Left").skew(1 - dist, 1.0) +
        TamUtils.getMove("Forward 3")
      case 6: return TamUtils.getMove("Lead Right").skew(2 - dist, 0.0) +
        TamUtils.getMove("Forward") +
        TamUtils.getMove("Extend Right").scale(2.0, 2.0).changebeats(2.0)
      case 7: return TamUtils.getMove("Lead Right").skew(2 - dist, 0.0) +
        TamUtils.getMove("Forward 2")
      default: return Path()  // should never happen
    }
  }

}
