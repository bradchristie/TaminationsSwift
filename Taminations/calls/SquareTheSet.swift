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

class SquareTheSet : Action {

  init() {
    super.init("Square the Set")
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    var xhome = d.number_couple == "1" ? -2.0 : 2.0
    if (ctx.dancers.count == 8) {
      switch (d.number.i) {
        case 1, 2: xhome = -3.0
        case 3, 8: xhome = -1.0
        case 4, 7: xhome = 1.0
        case 5, 6: xhome = 3.0
        default: break
      }
    }
    var yhome = (d.number_couple == "1") ^ (d.gender == .GIRL) ? 1.0 : -1.0
    if (ctx.dancers.count == 8) {
      switch (d.number.i) {
        case 1, 6: yhome = 1.0
        case 2, 5: yhome = -1.0
        case 3, 4: yhome = -3.0
        case 7, 8: yhome = 3.0
        default: break
      }
    }
    var ahome = d.number_couple == "1" ? 0.0 : .pi
    if (ctx.dancers.count == 8) {
      switch (d.number.i) {
        case 1, 2: ahome = 0.0
        case 3, 4: ahome = .pi / 2
        case 5, 6: ahome = .pi
        case 7, 8: ahome = .pi * 3 / 2
        default: break
      }
    }
    var tohome = Vector(xhome, yhome) - d.location
    let angle = d.tx.angle
    tohome = tohome.rotate(-angle)
    let adiff = ahome.angleDiff(angle)
    let turn = adiff.angleEquals(0.0) ? "Stand"
      : adiff.angleEquals(.pi / 4) ? "Eighth Left"
      : adiff.angleEquals(.pi / 2) ? "Quarter Left"
      : adiff.angleEquals(.pi * 3 / 4) ? "3/8 Left"
      : adiff.angleEquals(.pi) ? "U-Turn Right"
      : adiff.angleEquals(-3 * .pi / 4) ? "3/8 Right"
      : adiff.angleEquals(-.pi / 2) ? "Quarter Right"
      : adiff.angleEquals(-.pi / 4) ? "Eighth Right"
      : "Stand"
    return TamUtils.getMove(turn).changebeats(2.0).skew(tohome.x, tohome.y)
  }

}
