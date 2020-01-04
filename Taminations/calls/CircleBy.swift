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

import UIKit

class CircleBy : Action {

  override var level:LevelData { return LevelObject.find("c1") }
  override var requires:[String] { return ["b1/circle","b2/ocean_wave","b2/trade",
                                           "ms/hinge","ms/cast_off_three_quarters"]}

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    let a = norm.replace("circleby","").split("and",maxSplits: 2)
    if (a.count != 2) {
      throw CallError("Circle By <fraction> and <fraction or call>")
    }
    let (frac1,frac2) = (a[0],a[1])
    switch (frac1) {
      case "nothing" : break
      case "14", "12", "34" : try ctx.applyCalls("Circle Four Left \(frac1)")
      default :  throw CallError("Circle by what?")
    }
    try ctx.applyCalls("Step to a Wave")
    switch (frac2) {
      case "nothing" : break
      case "14" : try ctx.applyCalls("Hinge")
      case "12" : try ctx.applyCalls("Trade")
      case "34" : try ctx.applyCalls("Cast Off 3/4")
      default : try ctx.applyCalls(frac2)
    }
  }
}