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

class CrossFold : Action {
  
  override var level:LevelData { return LevelObject.find("ms") }

  init() {
    super.init("Cross Fold")
  }
  
  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Centers and ends cannot both cross fold
    if (ctx.dancers.any { d in
      d.data.active && d.data.center
    } &&
      ctx.dancers.any { d in
        d.data.active && d.data.end
      }) {
      throw CallError("Centers and ends cannot both Cross Fold")
    }
    try ctx.actives.forEach { d in
      //  Must be in a 4-dancer wave or line
      if (!d.data.center && !d.data.end) {
        throw CallError("General line required for Cross Fold")
      }
      //  Center beaus and end belles fold left
      let isright = d.data.beau ^ d.data.center
      let m = (isright) ? "Fold Right" : "Fold Left"
      let d2 = d.data.partner!
      let dist = d.distanceTo(d2)
      let dxscale = 0.75

      //  The y-distance of Fold is 2.0, here we adjust that value
      //  for various formations.  The dyoffset value computed is
      //  subtracted from the default 2.0 to get the final y offset.
      var dyoffset = 0.0
      if (ctx.isTidal() && d.data.end) {
        dyoffset = -0.5
      } else if (ctx.isTidal() && d.data.center) {
        dyoffset = 0.5
      } else if (d.data.end) {
        dyoffset = 2.0 - dist * 2
      } // which wll generally be -2.0
      else if (d.data.center) {
        dyoffset = 0.0
      }
      dyoffset *= (isright) ? 1 : -1

      d.path += TamUtils.getMove(m).scale(dxscale, 1.0).skew(0.0, dyoffset)

      //  Also set path for partner
      //  This is an adjustment to shift the dancers into a standard formation
      var m2 = "Stand"
      if (d.isRightOf(d2)) {
        m2 = "Dodge Right"
      } else if (d.isLeftOf(d2)) {
        m2 = "Dodge Left"
      }
      var myscale = 0.25
      if (ctx.isTidal()) {
        myscale = 0.25
      } else if (d2.data.end) {
        myscale = 0.5
      } else if (d2.data.center) {
        myscale = 0.0
      }
      d2.path += TamUtils.getMove(m2).scale(1.0, dist * myscale)
    }
  }

}
