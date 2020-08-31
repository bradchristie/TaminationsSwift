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

class SplitCirculate : Action {

  init() {
    super.init("Split Circulate")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    if (!ctx.isTBone()) {
      throw CallError("Only 2 boxes of 4 can Split Circulate")
    }
    try super.perform(ctx, index)
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    if (d.data.trailer) {
      return TamUtils.getMove("Forward 2").changebeats(3.0)
    }
    else if (d.data.leader) {
      let move = (ctx.dancerInFront(d) != nil) ? "Flip" : "Run"
      if (ctx.dancersToLeft(d).count % 2 == 1) {
        return TamUtils.getMove("\(move) Left")
      } else if (ctx.dancersToRight(d).count % 2 == 1) {
        return TamUtils.getMove("\(move) Right")
      }
    }
    throw CallError("Unable to calculate Split Circulate for dancer \(d)")
  }

}
