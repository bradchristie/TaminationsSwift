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

class Loop : Action {

  override var level: LevelData { LevelObject.find("c2") }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    var dir = ""
    switch (norm) {
      case let n where n.startsWith("left") : dir = "Left"
      case let n where n.startsWith("right") : dir = "Right"
      case let n where n.startsWith("in") : dir = (d.isCenterLeft) ? "Left" : "Right"
      case let n where n.startsWith("out") : dir = (d.isCenterLeft) ? "Right" : "Left"
      default: throw CallError("Invalid Loop direction")
    }
    let amount = Double(Int(norm.suffix(1),radix: 10)!)
    return TamUtils.getMove("Run \(dir)").scale(1.0, amount)
  }
}
