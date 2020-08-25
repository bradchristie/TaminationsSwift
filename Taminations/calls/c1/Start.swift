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

class Start : Action {

  override var level: LevelData { LevelObject.find("c1") }
  override var requires:[String] { ["b1/pass_thru","b2/trade","c1/finish"] }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    let finishCall = name.replaceFirstIgnoreCase("^start\\s+", "")
    //  There has to be a subset of dancers selected to start
    if (ctx.actives.count >= ctx.dancers.count) {
      throw CallError("Who is supposed to start?")
    }
    //  If the actives are facing, assume that the first part is Pass Thru
    //  Otherwise for now we will try a Trade
    let startCall = ctx.actives.all { it in
      ctx.dancerFacing(it)?.data.active == true
    } ? "Pass Thru" : "Trade"
    try ctx.applyCalls(startCall)
    ctx.dancers.forEach { it in it.data.active = true }
    try ctx.applyCalls("Finish \(finishCall)")
  }

}
