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

class Swing : Action {

  override var level: LevelData { LevelObject.find("a2") }
  override var requires:[String] { ["b2/trade"] }

  init() {
    super.init("Swing")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  If single wave in center, just those 4 Swing
    let ctx4 = CallContext(ctx,ctx.center(4))
    if (ctx4.isLines() && ctx4.isWaves() && !ctx.isTidal()) {
      try ctx4.applyCalls("Trade").appendToSource()
    }
    else if (ctx.isWaves()) {
      try ctx.applyCalls("Trade")
    }
    else {
      throw CallError("Dancers must be in mini-waves to Swing")
    }
  }

}
