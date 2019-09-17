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

class CrossRun : Action {

  override var level: LevelData { return LevelObject.find("b2") }

  init() {
    super.init("Cross Run")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Centers and ends cannot both cross run
    if (ctx.dancers.any { d in
      d.data.active && d.data.center
    } &&
      ctx.dancers.any { d in
        d.data.active && d.data.end
      }) {
      throw CallError("Centers and ends cannot both Cross Run")
    }
    //  We need to look at all the dancers, not just actives
    //  because partners of the runners need to dodge
    try ctx.dancers.forEach { d in
      if (d.data.active) {
        //  Must be in a 4-dancer wave or line
        if (!d.data.center && !d.data.end) {
          throw CallError("General line required for Cross Run")
        }
        //  Partner must be inactive
        guard let d2 = d.data.partner else {
          throw CallError("Nobody to Cross Run around")
        }
        if (d2.data.active) {
          throw CallError("Dancer and partner cannot both Cross Run")
        }
        //  Center beaus and end belles run left
        let isright = d.data.beau ^ d.data.center
        //  TODO check for runners crossing paths
        //    dancers would need to pass right shoulders
        let m = (isright) ? "Run Right" : "Run Left"
        let d3 = (isright)
          ? ctx.dancersToRight(d).elementAtOrNull(1)
          : ctx.dancersToLeft(d).elementAtOrNull(1)

        if (d3 == nil) {
          throw CallError("Unable to calcluate Cross Run")
        } else if (d3!.data.active) {
          throw CallError("Dancers cannot Cross Run each other")
        } else {
          d.path.add(TamUtils.getMove(m).scale(1.0, d.distanceTo(d3!) / 2.0))
        }
      } else {
        //  Not an active dancer
        //  If partner is active then this dancer needs to dodge
        let d2 = d.data.partner
        if (d2 != nil && d2!.data.active) {
          d.path.add(TamUtils.getMove((d.data.beau) ? "Dodge Right" : "Dodge Left"))
            .scale(1.0, d.distanceTo(d2!) / 2.0)
        }
      }
    }
  }

}