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

class QuarterTag : Action {

  override var level:LevelData { LevelObject.find("ms") }
  override var requires:[String] { ["ms/hinge","b1/face"] }

  private func centersHoldLeftHands(_ ctx:CallContext) -> Bool {
    ctx.actives.filter { d in d.data.center } . all { d in
        ctx.dancerToLeft(d)?.data.center ?? false
    }
  }
  private func centersHoldRightHands(_ ctx:CallContext) -> Bool {
    ctx.actives.filter { d in d.data.center } . all { d in
        ctx.dancerToRight(d)?.data.center ?? false
      }
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    let dir = norm.startsWith("left") ? "Left" : ""
    if (ctx.isTidal()) {
      try ctx.applyCalls("Center 4 Face Out While Outer 4 Face In",
        "Facing Dancers \(dir) Touch")
    } else {
      if (centersHoldLeftHands(ctx) && dir == "" ||
          centersHoldRightHands(ctx) && dir == "Left") {
        try ctx.applyCalls("Center 4 Hinge and Spread While Ends Face In")
      } else {
        try ctx.applyCalls("Centers \(dir) Hinge While Ends Face In")
      }
    }
  }


}
