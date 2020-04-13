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

class TurnAndDeal : Action {

  override var level: LevelData { LevelObject.find("a1") }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    let dir = ctx.tagDirection(d)
    let dist = !ctx.isTidal() ? 2.0 :
      d.data.center ? 1.5 : 0.5
    let sign = dir == "Left" ? 1.0 : -1.0
    return TamUtils.getMove("U-Turn \(dir)")
      .skew(sign*((norm.startsWith("left")) ? 1.0 : -1.0),dist*sign)

  }
}
