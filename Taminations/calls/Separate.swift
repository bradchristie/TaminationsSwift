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

class Separate : Action {

  init() {
    super.init("Separate")
  }
  
  //  We need to look at all the dancers, not just actives
  //  because sometimes the inactives need to move in
  override func perform(_ ctx: CallContext, _ index: Int) throws {
    if (ctx.actives.count != 4) {
      throw CallError("Who is going to Separate?")
    }

    //  Case 1 - Outer 4 Separate
    if (ctx.outer(4).all { $0.data.active} ) {
      try ctx.actives.forEach { d in
        let d2 = ctx.dancerClosest(d) { $0.data.active }!
        if (d2.isRightOf(d) && d.isFacingIn) {
          d.path += TamUtils.getMove("Quarter Left") +
            TamUtils.getMove("Lead Right").changebeats(2.0).scale(2.0, 2.0)
        } else if (d2.isRightOf(d) && d.isFacingOut) {
          d.path += TamUtils.getMove("Quarter Left") +
            TamUtils.getMove("Lead Left").changebeats(2.0).scale(2.0, 2.0)
        } else if (d2.isLeftOf(d) && d.isFacingIn) {
          d.path += TamUtils.getMove("Quarter Right") +
            TamUtils.getMove("Lead Left").changebeats(2.0).scale(2.0, 2.0)
        } else if (d2.isLeftOf(d) && d.isFacingOut) {
          d.path += TamUtils.getMove("Quarter Right") +
            TamUtils.getMove("Lead Right").changebeats(2.0).scale(2.0, 2.0)
        } else {
          throw CallError("Unable to figure out how to Separate")
        }
      }
    }

    //  Case 2 - Centers facing out Separate
    else if (ctx.actives.all { $0.isFacingOut} ) {
      try ctx.actives.forEach { d in
        let d2 = ctx.dancerClosest(d) { it in
          it.data.active &&
            (it.isRightOf(d) || it.isLeftOf(d))
        }
        if (d2 != nil && d2!.isRightOf(d)) {
          d.path += TamUtils.getMove("Run Left")
        } else if (d2 != nil && d2!.isLeftOf(d)) {
          d.path += TamUtils.getMove("Run Right")
        } else {
          throw CallError("Unable to figure out how to Separate")
        }
      }
      //  Other dancers need to move in
      ctx.dancers.filter { d in !d.data.active }.forEach { d in
        //  Find the other inactive dancer that this dancer will face
        let d2q = ctx.dancerClosest(d) { it in !it.data.active && it.isInFrontOf(d) }
        if let d2 = d2q {
          //  Space the dancers 2 units apart
          let dist = d.distanceTo(d2) / 2 - 1
          d.path += TamUtils.getMove("Forward").scale(dist, 1.0).changebeats(3.0)
        }
      }  
    }

    //  Did not match Case 1 or Case 2
    else {
      throw CallError("Cannot figure out how to Separate")
    }
  }

}
