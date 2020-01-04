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

class WheelAround : Action {

  override var level:LevelData { return LevelObject.find("b2") }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    let d2q = [d.data.partner, ctx.dancerToRight(d), ctx.dancerToLeft(d)].compactMap {
        $0
      }
      .filter {
        ctx.isInCouple($0)
      }.first
    guard let d2 = d2q else {
      throw CallError("Dancer \(d) is not part of a Facing Couple")
    }
    if (!d2.data.active) {
      throw CallError("Dancer \(d) must Wheel Around with partner")
    }
    let move =
      norm.startsWith("reverse") ?
        d2.isRightOf(d)
          ? "Beau Reverse Wheel"
          : "Belle Reverse Wheel"
        : d2.isRightOf(d)
          ? "Beau Wheel"
          : "Belle Wheel"
    return TamUtils.getMove(move)
  }
}
