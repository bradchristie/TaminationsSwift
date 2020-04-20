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

class StaggerConcept : ModifiedFormationConcept {

  override var level: LevelData { LevelObject.find("c2") }
  override var conceptName: String { "Stagger" }
  private var startFormation = ""
  override var formationName:String { startFormation }
  override var modifiedFormationName:String { "Double Pass Thru" }

  //  Starting formation could be blocks leaning left or right
  //  So check both and remember which one
  override func checkFormation(_ ctx: CallContext) -> Bool {
    let ctx1 = CallContext(TamUtils.getFormation("Facing Blocks Right"))
    let ctx2 = CallContext(TamUtils.getFormation("Facing Blocks Left"))
    if (ctx.matchFormations(ctx1,sexy:false,fuzzy:true,rotate:180,handholds:false) != nil) {
      startFormation = "Facing Blocks Right"
      return true
    }
    if (ctx.matchFormations(ctx2,sexy:false,fuzzy:true,rotate:180,handholds:false) != nil) {
      startFormation = "Facing Blocks Left"
      return true
    }
    return false
  }

  override func reformFormation(_ ctx: CallContext) -> Bool {
    //  If the dancers have rotated 90 degrees, then we need to switch to
    //  the other block to get the dancers back on the same footprints
    ctx.dancers[0].animate(beat:0.0)
    let a1 = ctx.dancers[0].angleFacing
    ctx.dancers[0].animateToEnd()
    let a2 = ctx.dancers[0].angleFacing
    let finalFormation =
    (a1.angleDiff(a2).abs.isAround(.pi/2) ^ (startFormation=="Facing Blocks Right"))
     ? "Facing Blocks Right"
     : "Facing Blocks Left"
    return ctx.adjustToFormation(finalFormation)
  }

}
