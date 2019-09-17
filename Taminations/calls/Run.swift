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

class Run : Action {

  override var level: LevelData { return LevelObject.find("b2") }
  
  init() {
    super.init("Run")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  We need to look at all the dancers, not just actives
    //  because partners of the runners need to dodge
    try ctx.dancers.forEach { d in
      if (d.data.active) {
        //  Find dancer to run around
        //  Usually it's the partner
        guard var d2 = d.data.partner else {
          throw CallError("Dancer ${d.number} has nobody to Run around")
        }
        //  But special case of t-bones, could be the dancer on the other side,
        //  check if another dancer is running around this dancer's "partner"
        let d3 = d2.data.partner
        if (d != d3 && d3 != nil && d3!.data.active) {
          guard let d2q = d3!.isRightOf(d) ? ctx.dancerToRight(d) : ctx.dancerToLeft(d) else {
            throw CallError("Dancer ${d.number} has nobody to Run around")
          }
          d2 = d2q
        }
        if (d2.data.active) {
          throw CallError("Dancers cannot Run around each other.")
        }
        let m = d2.isRightOf(d) ? "Run Right" : "Run Left"
        let dist = d.distanceTo(d2)
        d.path.add(TamUtils.getMove(m).scale(1.0, dist / 2))
        //  Also set path for partner
        let m2 = d.isRightOf(d2) ? "Dodge Right"
          : d.isLeftOf(d2) ? "Dodge Left"
          : d.isInFrontOf(d2) ? "Forward 2"
          : d.isInBackOf(d2) ? "Back 2"   //  really ???
          : "Stand"  // should never happen
        d2.path.add(TamUtils.getMove(m2).scale(1.0, dist / 2))
      }
    }
  }

}