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

  override var level:LevelData { return LevelObject.find("ms") }
  override var requires:[String] { return ["ms/hinge","b1/face"] }

  init() {
    super.init("Quarter Tag")
  }

  private func centersHoldLeftHands(_ ctx:CallContext) -> Bool {
    return ctx.actives.any { d in
      d.data.center && (ctx.dancerToLeft(d)?.data.center ?? false)
    }
  }

  override func performCall(_ ctx: CallContext, _ index: Int) throws {
    if (centersHoldLeftHands(ctx)) {
      try ctx.applyCalls("Center 4 Hinge and Spread While Ends Face In")
    } else {
      try ctx.applyCalls("Centers Hinge While Ends Face In")
    }
  }


}
