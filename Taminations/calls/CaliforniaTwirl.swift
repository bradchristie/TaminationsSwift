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

class CaliforniaTwirl : Action {

  init() {
    super.init("California Twirl")
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    if (d.gender == .BOY) {
      let d2 = ctx.dancerToRight(d)
      if (d2 == nil || d2!.gender != .GIRL || !d2!.data.active) {
        throw CallError("Dancer $d cannot California Twirl")
      }
      let dist = d.distanceTo(d2!)
      return TamUtils.getMove("Run Right")
        .changehands(Hands.GRIPRIGHT)
        .scale(dist/2,dist/2)

    } else if (d.gender == .GIRL) {
      let d2 = ctx.dancerToLeft(d)
      if (d2 == nil || d2!.gender != .BOY || !d2!.data.active) {
        throw CallError("Dancer $d cannot California Twirl")
      }
      let dist = d.distanceTo(d2!)
      return TamUtils.getMove("Flip Left")
        .changehands(Hands.GRIPLEFT)
        .scale(dist/2,dist/2)

    } else {
      throw CallError("Phantoms cannot Twirl")  // cannot happen so far
    }
  }

}
