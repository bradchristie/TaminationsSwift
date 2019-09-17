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


class Squeeze : Action {

  override var level:LevelData { return LevelObject.find("c1") }


  init() {
    super.init("Squeeze")
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    guard let d2 = ctx.dancerToLeft(d) ?? ctx.dancerToRight(d) else {
      throw CallError("No dancer to Squeeze with \(d)")
    }
    let dist = d.distanceTo(d2)
    let isClose = dist < 2.0 || dist.isApprox(2.0)
    let sameDirection = d.angleFacing.angleEquals(d2.angleFacing)
    let tradePath =
      d2.isLeftOf(d) && sameDirection ? TamUtils.getMove("Flip Left")
        : d2.isRightOf(d) && sameDirection ? TamUtils.getMove("Run Right")
        : d2.isLeftOf(d) ? TamUtils.getMove("Swing Left")
        : TamUtils.getMove("Swing Right")
    let dodgePath = d2.isLeftOf(d) ^ isClose
      ? TamUtils.getMove("Dodge Left") : TamUtils.getMove("Dodge Right")
    if (isClose) {
      return tradePath + dodgePath
    } else {
      return dodgePath.scale(1.0, (dist-2.0)/4.0) + tradePath
    }
  }

}
