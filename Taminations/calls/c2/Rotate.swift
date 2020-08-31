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

class Rotate : Action {

  override var level:LevelData { LevelObject.find("c2") }
  override var requires:[String] {
    ["b2/wheel_around","ms/hinge"]
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    if (!ctx.isLines() || !ctx.dancers.all { ctx.isInCouple($0)} ) {
      throw CallError("Unable to Rotate from this formation")
    }
    let leaders = ctx.dancers.filter { $0.data.leader }
    let trailers = ctx.dancers.filter { $0.data.trailer }
    if (leaders.count > 0) {
      try ctx.subContext(leaders) {
        try $0.applyCalls("Half Wheel Around")
      }
    }
    if (trailers.count > 0) {
      try ctx.subContext(trailers) {
        try $0.applyCalls("Half Reverse Wheel Around")
      }
    }
    try ctx.applyCalls("Couples Hinge")
    if (norm.endsWith("12")) {
      try ctx.applyCalls("Couples Hinge")
    }
    if (norm.endsWith("34")) {
      try ctx.applyCalls("Couples Hinge","Couples Hinge")
    }
  }

}
