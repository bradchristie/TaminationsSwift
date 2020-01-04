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

class BoxtheGnat : Action {

  init() {
    super.init("Box the Gnat")
  }

  private func checkOtherDancer(_ d:Dancer, _ d2:Dancer?) throws -> Dancer {
    guard let other = d2 else {
      throw CallError("Cannot find dancer to turn with \(d.number)")
    }
    if (!other.data.active) {
      throw CallError("Cannot find dancer to turn with ${d.number}")
    }
    if (other.gender == d.gender) {
      throw CallError("Same gender cannot Box the Gnat")
    }
    return other
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    if (ctx.isInWave(d)) {
      let d2 = try checkOtherDancer(d, ctx.dancerToRight(d))
      let dist = d.distanceTo(d2)
      let offset =
        dist > 1.5 && d.data.end ? -dist
          : dist > 1.5 && d.data.center ? 0.0
          : -dist / 2.0
      return TamUtils.getMove((d.gender == Gender.BOY) ? "U-Turn Right" : "U-Turn Left").skew(1.0, offset).changehands(Hands.GRIPRIGHT)
    } else {
      let d2 = try checkOtherDancer(d, ctx.dancerFacing(d))
      let dist = d.distanceTo(d2)
      let cy1 = (d.gender == Gender.BOY) ? 1.0 : 0.1
      let y4 = (d.gender == Gender.BOY) ? -2.0 : 2.0
      let hands = (d.gender == Gender.BOY) ? Hands.GRIPLEFT : Hands.GRIPRIGHT
      let m = Movement(
        fullbeats: 4.0, hands: hands,
        cx1: 1.0, cy1: cy1, cx2: dist / 2, cy2: cy1, x2: dist / 2 + 1, y2: 0.0,
        cx3: 1.3, cx4: 1.3, cy4: y4, x4: 0.0, y4: y4)
      return Path(m)
    }
  }
}
