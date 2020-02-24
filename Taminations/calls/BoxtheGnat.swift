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

  private func checkOtherDancer(_ d:Dancer, _ d2:Dancer?) -> Dancer? {
    guard let other = d2 else {
      return nil
    }
    if (!other.data.active) {
      return nil
    }
    if (other.gender == d.gender) {
      return nil
    }
    return other
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    if (ctx.isInWave(d)) {
      guard let d2 = checkOtherDancer(d, ctx.dancerToRight(d)) else {
        return try ctx.dancerCannotPerform(d,name)
      }
      let dist = d.distanceTo(d2)
      let offset =
        dist > 1.5 && d.data.end ? -dist
          : dist > 1.5 && d.data.center ? 0.0
          : -dist / 2.0
      return TamUtils.getMove((d.gender == Gender.BOY) ? "U-Turn Right" : "U-Turn Left").skew(1.0, offset).changehands(Hands.GRIPRIGHT)
    } else {
      guard let d2 = checkOtherDancer(d, ctx.dancerFacing(d)) else {
        return try ctx.dancerCannotPerform(d,name)
      }
      let dist = d.distanceTo(d2)
      let cy1 = (d.gender == Gender.BOY) ? 1.0 : 0.1
      let y4 = (d.gender == Gender.BOY) ? -2.0 : 2.0
      let hands = (d.gender == Gender.BOY) ? Hands.GRIPLEFT : Hands.GRIPRIGHT
      let m = Movement(
        fullbeats: 4.0, hands: hands,
        btranslate: Bezier(x1:0.0, y1:0.0, ctrlx1: 1.0, ctrly1: cy1,
                           ctrlx2: dist / 2, ctrly2: cy1, x2: dist / 2 + 1, y2: 0.0),
        brotate: Bezier(x1:0.0, y1:0.0, ctrlx1: 1.3, ctrly1: 0.0,
                       ctrlx2: 1.3, ctrly2: y4, x2: 0.0, y2: y4))
      return Path(m)
    }
  }
}
