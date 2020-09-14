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

class Bounce : Action {

  override var level: LevelData { LevelObject.find("c2") }
  override var requires:[String] { ["b1/veer", "b1/turn_back"] }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Figure out which way to veer
    let centerBelles = ctx.actives.filter {
      d in d.data.center && d.data.belle
    }
    let centerBeaus = ctx.actives.filter {
      d in d.data.center && d.data.beau
    }
    var dir = ""
    if (centerBeaus.count==0 && centerBelles.count > 0) {
      dir = "Right"
    } else if (centerBeaus.count > 0 && centerBelles.count == 0) {
      dir = "Left"
    } else {
      throw CallError("Unable to calculate Bounce")
    }

    //  Remember who to bounce
    let who = norm.replaceFirst("bounce(the)?","")
    let whoctx = CallContext(ctx,ctx.actives)
    if (!who.matches("no(body|one)")) {
      try whoctx.applySpecifier(who)
    }
    //  Do the veer
    try ctx.applyCalls("Veer \(dir)")
    //  Do the bounce
    if (!who.matches("no(body|one)")) {
      try whoctx.applyCalls("Face \(dir)","Face \(dir)").appendToSource()
    }
  }

}
