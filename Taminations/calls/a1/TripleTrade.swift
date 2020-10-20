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

class TripleTrade : Action {

  override var level:LevelData { return LevelObject.find("a1") }
  override var requires:[String] { return ["b2/trade"] }

  init() {
    super.init("Triple Trade")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Check to see if tehre's a line of 6
    //  If so, do it with those dancers
    let lineOf6 = ctx.dancers.filter { d in
      ctx.dancersToRight(d).count + ctx.dancersToLeft(d).count == 5
    }
    if (lineOf6.count == 6) {
      try ctx.subContext(lineOf6) { ctx2 in
        try ctx2.applyCalls("Trade")
      }
    }
    else {
      //  Otherwise just try with center 6 however they are arranged
      try ctx.applyCalls("Center 6 Trade")
    }
  }

}
