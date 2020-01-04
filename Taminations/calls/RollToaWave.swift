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

class RollTo : Action {

  //  Turn tightly in the direction while moving a little back
  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    let move = norm.startsWith("left") ? "Flip Left" : "Flip Right"
    return TamUtils.getMove(move).scale(1.0,0.25).skew(-0.5,0.0)
  }
}

class RollToaWave : Action {

  override var level:LevelData { LevelObject.find("a1") }
  override var requires: [String] { ["b2/ocean_wave"] }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    let dir = (norm.startsWith("left")) ? "Left" : "Right"
    let wave = (norm.startsWith("left")) ? "Left-Hand" : ""
    //  Have the leaders (if any) turn back the indicated direction
    //  Then everybody Step to a Wave
    let roller = "Leaders \(dir) RollTo"
    if (ctx.actives.any { it in it.data.leader }) {
      try ctx.applyCalls(roller, "Step to a \(wave) Wave")
    } else {
      try ctx.applyCalls("Step to a \(wave) Wave")
    }

    //  Post-process - take out the filler for the trailers while
    //  leaders were turning back, then set all to 4 beats
    ctx.dancers.forEach { d in
      //  a bit of a hack
      if (d.path.movelist.count == 2 && !d.path.movelist.first!.fromCall) {
        let m = d.path.pop()
        d.path.clear()
        d.path.add(m)
      }
      d.path.changebeats(4.0)
    }


  }
}
