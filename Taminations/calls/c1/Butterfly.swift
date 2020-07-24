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

class Butterfly : ModifiedFormationConcept {

  override var level: LevelData { LevelObject.find("c1") }
  override var conceptName: String { "Butterfly" }
  override var modifiedFormationName: String { "Double Pass Thru" }
  override var formationName: String { "Butterfly RH" }

  override func reformFormation(_ ctx: CallContext) -> Bool {
    //  First try the usual way
    if (!super.reformFormation(ctx)) {
      //  That didn't work, we are too far off from a butterfly
      //  So first just concentrate on the centers
      let centers = CallContext(ctx,ctx.center(4))
      if (centers.adjustToFormation("Facing Couples Close",rotate: 180)) {
        //  And now use the base method to fix the outer 4
        centers.appendToSource()
        return super.reformFormation(ctx)
      }
      return false
    }
    return true
  }

}
