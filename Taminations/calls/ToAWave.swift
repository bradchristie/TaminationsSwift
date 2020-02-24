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

class ToAWave : Action {

  override var level:LevelData { LevelObject.find("c1") }

  init() {
    super.init("to a Wave")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    guard ctx.callstack.count >= 2 else {
      throw CallError("What to a Wave")
    }
    //  Assume the last move is an Extend from a wave
    ctx.actives.forEach { d in
      d.path.pop()
    }
    //  Now let's see if they are in waves
    ctx.analyze()
    try ctx.actives.forEach { d in
      if (!ctx.isInWave(d)) {
        throw CallError("Unable to end in Wave")
      }
    }

  }

}
