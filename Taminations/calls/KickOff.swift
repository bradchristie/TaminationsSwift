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


class KickOff : Action {

  override var level: LevelData { LevelObject.find("c2") }
  override var requires:[String] { ["b2/run","plus/anything_and_roll"] }  

  init() {
    super.init("Kick Off")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Active dancers Run and Roll
    try ctx.applyCalls("Run and Roll")
    //  Inactive dancers that moved do a Partner Tag
    ctx.dancers.filter {
      !$0.data.active && $0.path.movelist.count > 0
    }.forEach { d in
      let m = d.path.shift()!
      let dy = m.btranslate.endPoint.y
      if (dy > 0) {
        d.path = TamUtils.getMove("Quarter Left").changebeats(3.0).skew(0.0, dy)
      }
    else if (dy < 0) {
      d.path = TamUtils.getMove("Quarter Right").changebeats(3.0).skew(0.0, dy)
    }
  }

  }
}