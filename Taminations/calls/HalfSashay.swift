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

class HalfSashay : Action {

  init() {
    super.init("Half Sashay")
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {

    //  Figure out who we sashay with
    var d2 = d
    if (d.data.partner != nil && ctx.actives.contains(d.data.partner!) &&
      (d.data.beau || d.data.belle)) {
      d2 = d.data.partner!
    } else if (ctx.dancerToRight(d) != nil &&
      ctx.actives.contains(ctx.dancerToRight(d)!)) {
      d2 = ctx.dancerToRight(d)!
    } else if (ctx.dancerToLeft(d) != nil &&
      ctx.actives.contains(ctx.dancerToLeft(d)!)) {
      d2 = ctx.dancerToLeft(d)!
    } else {
      throw CallError("Dancer \(d) has nobody to Sashay with")
    }
    let move = d2.isLeftOf(d) ?  "Sashay Left" : "BackSashay Right"
    let dist = d.distanceTo(d2)

    return TamUtils.getMove(move).scale(1.0,dist/2.0)

  }

}
