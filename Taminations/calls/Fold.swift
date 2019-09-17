/*

  Taminations Square Dance Animations
  Copyright (C) 2019 Brad Christie

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

class Fold : Action {

  override var level:LevelData { return LevelObject.find("ms") }

  init() {
    super.init("Fold")
  }
  
  //  We need to work with all the dancers, not just actives
  //  because partners of the folders need to adjust
  //  so we get a standard formation that can be used for more calls
  override func perform(_ ctx: CallContext, _ index: Int) throws {
    try ctx.actives.forEach { d in
      //  Find dancer to fold in front of
      //  Usually it's the partner
      guard let d2 = d.data.partner else {
        throw CallError("Dancer \(d) has nobody to Fold in front")
      }
      if (d2.data.active || d2.data.partner != d) {
        throw CallError("Dancer \(d) has nobody to Fold in front")
      }
      let m = d2.isRightOf(d) ? "Fold Right" : "Fold Left"
      let dist = d.distanceTo(d2)
      let dxscale = 0.75
      let dyoffset =
        (ctx.isTidal() ? 1.5
          : d.data.end ? 2.0 - dist
          : d.data.center ? 2.0
          : 1.0
        ) * (d2.isRightOf(d) ? 1 : -1)
      d.path += TamUtils.getMove(m).scale(dxscale, 1.0).skew(0.0, dyoffset)
      //  Also set path for partner
      let m2 = d.isRightOf(d2) ? "Dodge Right"
        : d.isLeftOf(d2) ? "Dodge Left"
        : "Stand"  // should never happen

      let myscale = ctx.isTidal() ? 0.25
        : d2.data.end ? 0.5
        : d2.data.center ? 0.0
        : 0.25
      d2.path += TamUtils.getMove(m2).scale(1.0, dist * myscale)
    }
  }

}
