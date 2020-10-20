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

class TagYourNeighbor : Action {

  override var level: LevelData { LevelObject.find("c2") }
  override var requires:[String] { ["ms/fraction_tag",
                                    "plus/follow_your_neighbor",
                                    "c1/cross_your_neighbor",
                                    "c2/criss_cross_your_neighbor"] }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    let left = norm.contains("left") ? "Left" : ""
    let vertical = norm.contains("vertical") ? "Vertical" : ""
    var basecall = ""
    switch (norm.replace("left", "")) {
      case "tagyourneighbor" : basecall = "Follow Your Neighbor"
      case "tagyourcrossneighbor" : basecall = "Cross Your Neighbor"
      case "tagyourcrisscrossneighbor" : basecall = "Criss Cross Your Neighbor"
      default : throw CallError("Tag what?")  // should not happen
    }
    try ctx.applyCalls("\(vertical) \(left) Half Tag",basecall)
  }

}
