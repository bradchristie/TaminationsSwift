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

class TouchAQuarter : Action {

  override var level:LevelData { return LevelObject.find("b2") }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    guard let d2 = ctx.dancerFacing(d) else {
      throw CallError("Dancer ${d.number} cannot Touch a Quarter")
    }
    var move = TamUtils.getMove("Extend Left")
      .scale(d.distanceTo(d2)/2.0,1.0)
      .add(TamUtils.getMove("Hinge Right"))
    if (norm.startsWith("left")) {
      move = move.reflect()
    }
    return move
  }

}
