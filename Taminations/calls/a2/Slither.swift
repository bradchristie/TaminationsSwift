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

class Slither : Action {

  override var level: LevelData { LevelObject.find("a2") }

  init() {
    super.init("Slither")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  If single wave in center, then very centers trade
    let ctx4 = CallContext(ctx, ctx.center(4))
    if (ctx.dancers.count == 8 && ctx4.isLines() && !ctx.isTidal()) {
      ctx.dancers.filter { !$0.data.verycenter }.forEach {
        $0.data.active = false
      }
    } else {
      //  Otherwise, all centers trade
      //  Check that it's not a partner trade
      let ctxc = CallContext(ctx, ctx.dancers.filter { $0.data.center })
      if (!ctxc.isWaves()) {
        throw CallError("Centers must be in a mini-wave.")
      }
      ctx.dancers.filter { !$0.data.center }.forEach {
        $0.data.active = false
      }
    }
    try super.perform(ctx, index)
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    if (ctx.dancerToRight(d)?.data.active == true) {
      return TamUtils.getMove("BackSashay Right")
        .scale(1.0, d.distanceTo(ctx.dancerToRight(d)!)/2.0)
    }
    else if (ctx.dancerToLeft(d)?.data.active == true) {
      return TamUtils.getMove("BackSashay Left")
        .scale(1.0, d.distanceTo(ctx.dancerToLeft(d)!)/2.0)
    }
    else {
      throw CallError("Unable to calculate Sither.")
    }
  }

}


