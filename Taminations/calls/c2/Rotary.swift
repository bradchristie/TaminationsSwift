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

class Rotary : Action {

  override var level:LevelData { LevelObject.find("c2") }
  override var requires:[String] {
    ["b2/wheel_around","ms/hinge"]
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    let anyCall = name.replaceIgnoreCase("rotary\\s*", "")
    try ctx.applyCalls("Pull By")
    ctx.analyze()
    try ctx.subContext(ctx.outer(4)) { ctx2 in
      try ctx2.applyCalls("Courtesy Turn and Roll")
    }
    try ctx.subContext(ctx.center(4)) { ctx2 in
      try ctx2.applyCalls("Step to a Left Hand Wave",anyCall)
    }
  }

}
