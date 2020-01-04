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

class StarThru : Action {

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    //  Must be facing dancers, opposite gender
    guard let d2 = ctx.dancerFacing(d) else {
      throw CallError("Dancer \(d) has nobody to Star Thru with")
    }
    if (d2.gender == d.gender) {
      throw CallError("Cannot Star Thru with same gender.")
    }
    let dist = d.distanceTo(d2)
    var move = TamUtils.getMove("Extend Left").scale(dist / 2, 0.5) +
      ((d.gender == Gender.BOY)
        ? TamUtils.getMove("Lead Right").scale(1.0, 0.5)
        : TamUtils.getMove("Quarter Left").skew(1.0, -0.5))
    //  "left" star thru is used by double/triple star thru
    if (norm.startsWith("left")) {
      move = move.reflect()
    }
    return move
  }

}
