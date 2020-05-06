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

class Slide : Action {

  override var level: LevelData { LevelObject.find("a2") }

  init() {
    super.init("Slide")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  If single wave in center, just those 4 Slide
    if try (!ctx.subContext(ctx.center(4)) { ctx2 in
      if (ctx.dancers.count > 4 && ctx2.isLines() && ctx2.isWaves() && !ctx.isTidal()) {
        ctx2.analyze()
        try ctx2.applyCalls("Slide")
      }
    }) {
      if (ctx.actives.all { ctx.isInWave($0) }) {
        try super.perform(ctx, index)
      }
      else {
        throw CallError("Dancers must be in mini-waves to Slide")
      }
    }
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    guard let d2 = d.data.partner else {
      throw CallError("Unable to calculate Slide.")
    }
    let dist = d.distanceTo(d2)
    if (d.data.beau) {
      return TamUtils.getMove("BackSashay Right").scale(1.0, dist / 2.0)
    }
    else if (d.data.belle) {
      return TamUtils.getMove("BackSashay Left").scale(1.0, dist / 2.0)
    }
    else {
      throw CallError("Unable to calculate Slide.")
    }
  }
}
