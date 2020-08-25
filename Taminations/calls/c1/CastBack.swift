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

class CastBack : Action {

  override var level:LevelData { LevelObject.find("c1") }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Either the leaders Cast Back or the caller has
    //  to specify the dancers
    let leaders = ctx.dancers.filter { $0.data.leader }
    let casters = (ctx.actives.count < ctx.dancers.count)
      ? ctx.actives
      : (leaders.count > 0 && leaders.count < ctx.dancers.count)
      ? leaders : Array<Dancer>()
    if (casters.count <= 0) {
      throw CallError("Who is going to Cast Back?")
    }
    ctx.dancers.forEach { it in it.data.active = casters.contains(it) }
    try super.perform(ctx, index)
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    let dir = (d.isCenterRight ^ (norm == "crosscastback")) ? "Left" : "Right"
    let move = (d.isCenterRight && norm == "crosscastback") ? "Flip" : "Run"
    let scale = (norm == "crosscastback") ? 2.0 : 1.0
    return TamUtils.getMove("\(move) \(dir)").scale(1.0,scale).skew(-2.0,0.0)
  }

}
