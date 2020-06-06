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

class CrossOverCirculate : Action {

  override var level:LevelData { return LevelObject.find("a1") }

  init() {
    super.init("Cross Over Circulate")
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    if (d.data.leader) {
      //  Find another active dancer in this line
      guard let d2 = (ctx.actives.first { dd in
        dd != d && (dd.isRightOf(d) || dd.isLeftOf(d))
      }) else {
        throw CallError("Unable to calculate Cross Over Circulate for dancer \(d)")
      }
      //  Centers <-> Ends
      if (!(d.data.center ^ d2.data.end)) {
        throw CallError("Incorrect circulate path for Cross Over Circulate")
      }
      let move = (d2.isRightOf(d)) ? "Run Right" : "Run Left"
      //  Pass right shoulders if necessary
      let xScale = (d2.isRightOf(d) && d2.data.leader) ? 2.0 : 1.0
      let yScale = d.distanceTo(d2) / 2.0
      return TamUtils.getMove(move).scale(xScale,yScale)

    } else if (d.data.trailer) {
      //  Find the dancer in the other line to move to
      guard let d2 = (ctx.actives.first { dd in
        dd != d && !dd.isOpposite(d) && !dd.isLeftOf(d) && !dd.isRightOf(d)
      }) else {
        throw CallError("Unable to calculate Cross Over Circulate for dancer \(d)")
      }
      //  Centers <-> Ends
      if (!(d.data.center ^ d2.data.end)) {
        throw CallError("Incorrect circulate path for Cross Over Circulate")
      }
      let v = d.vectorToDancer(d2)
      //  Pass right shoulders if necessary
      if (d2.data.trailer && v.y > 0) {
        return TamUtils.getMove("Extend Left").changebeats(v.x - 1).scale(v.x - 1, v.y) +
          TamUtils.getMove("Forward")
      } else if (d2.data.trailer && v.y < 0) {
        return TamUtils.getMove("Forward") +
          TamUtils.getMove("Extend Right").scale(v.x - 1, -v.y).changebeats(v.x - 1)
      } else if (v.y > 0) {
        return TamUtils.getMove("Extend Left").changebeats(v.x).scale(v.x, v.y)
      } else {
        return TamUtils.getMove("Extend Right").changebeats(v.x).scale(v.x, -v.y)
      }

    } else {
      throw CallError("Unable to calculate Cross Over Circulate for dancer \(d)")
    }
  }

}
