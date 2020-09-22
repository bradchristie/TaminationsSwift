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

class FlipYourNeighbor : Action {

  override var level: LevelData { LevelObject.find("c2") }
  override var requires:[String] { [
    "c1/flip_the_line",
    "plus/follow_your_neighbor",
    "c1/cross_your_neighbor",
    "c2/criss_cross_your_neighbor"
  ] }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    let secondCall =
      norm == "flipyourneighbor" ? "Follow Your Neighbor" :
      norm == "flipyourcrossneighbor" ? "Follow Your Cross Neighbor" :
      norm == "flipyourcrisscrossneighbor" ? "Follow Your Criss Cross Neighbor" : ""
    try ctx.applyCalls("Flip the Line 1/2",secondCall)
  }

}
