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

class PartnerTag : Action {

  override var level:LevelData { return LevelObject.find("a1") }

  init() {
    super.init("Partner Tag")
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    //  Generally Partner Tag is with partner, but there can be exceptions
    let d2q = [d.data.partner, ctx.dancerToRight(d), ctx.dancerToLeft(d)]
      .compactMap { $0 }
      .filter { it in it.data.active }.first
    guard let d2 = d2q else {
      throw CallError("Dancer \(d) cannnot Partner Tag")
    }
    let dist = d.distanceTo(d2)
    return d2.isRightOf(d)
      ? TamUtils.getMove("Lead Right").scale(0.5, dist / 2) +
        TamUtils.getMove("Extend Right").scale(dist / 2, 0.5)
      : TamUtils.getMove("Quarter Left").skew(-0.5, dist / 2) +
        TamUtils.getMove("Extend Right").scale(dist / 2, 0.5)
  }
}
