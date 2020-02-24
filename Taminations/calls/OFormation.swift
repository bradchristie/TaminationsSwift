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

class OFormation : Action {

  override var level:LevelData { LevelObject.find("c1") }

  override func perform(_ ctx: CallContext, _ index: Int) throws {

    //  Find outer and inner dancers, and confirm we have on "O"
    let outer = ctx.dancers.filter { d in
      (ctx.dancerInFront(d)?.distanceTo(d) ?? 0.0).isAbout(6.0) ||
      (ctx.dancerInBack(d)?.distanceTo(d) ?? 0.0).isAbout(6.0) }
    let inner = ctx.dancers.filter { d in
      (ctx.dancerToLeft(d)?.distanceTo(d) ?? 0.0).isAbout(6.0) ||
      (ctx.dancerToRight(d)?.distanceTo(d) ?? 0.0).isAbout(6.0) }
    if (outer.count != 4 || inner.count != 4) {
      throw CallError("Formation is not an O")
    }

    //  Slide in the inner dancers
    outer.forEach { d in d.data.active = false }
    try ctx.applyCalls("Slide In")
    outer.forEach { d in d.data.active = true }

    //  Do the call
    try ctx.applyCalls(name.lowercased().replaceFirst("o",""))

    //  Merge the slide in adjustment into the start of the call
    inner.forEach { d in
      if (d.path.movelist.count > 1) {
        let dy = d.path.movelist.first!.btranslate.endPoint.y
        d.path.shift()
        d.path.skewFirst(0.0,dy)
      }
    }
    //  Outer 4 no longer need to stand for inner 4 to adjust
    outer.forEach { d in d.path.shift() }

    //  Reform the O
    //  First find the major axis
    ctx.analyze()
    var (xmax,ymax) = (0.0,0.0)
    ctx.dancers.forEach { d in
      xmax = max(xmax,d.location.x)
      ymax = max(ymax,d.location.y)
    }
    //  Now move the centers in the other direction
    //  and adjust the outer dancers
    let newcenters = ctx.dancers.filter { it in it.data.center }
    if (newcenters.count != 4) {
      throw CallError("Unable to reform the O")
    }
    try ctx.dancers.forEach { d in
      var (dx, dy) = (0.0, 0.0)
      //  Centers are 6 units apart, ends 2 units apart
      let goal = (d.data.center) ? 6.0 : 2.0
      if (d.angleFacing.abs.isAround(.pi / 2) ^ (ymax > xmax)) {
        //  Moving forward or back
        if (d.isFacingIn) {
          guard let d2 = ctx.dancerInFront(d) else {
            throw CallError("Unable to reform the O")
          }
          dx = -(goal - d.distanceTo(d2)) / 2.0
        }
        if (d.isFacingOut) {
          guard let d2 = ctx.dancerInBack(d) else {
            throw CallError("Unable to reform the O")
          }
          dx = (goal - d.distanceTo(d2)) / 2.0
        }
      } else {
        //  Moving left or right
        if (d.isCenterRight) {
          guard let d2 = ctx.dancerToRight(d) else {
            throw CallError("Unable to reform the O")
          }
          dy = (goal - d.distanceTo(d2)) / 2.0
        }
        if (d.isCenterLeft) {
          guard let d2 = ctx.dancerToLeft(d) else {
            throw CallError("Unable to reform the O")
          }
          dy = -(goal - d.distanceTo(d2)) / 2.0
        }
      }
      d.path.skewFromEnd(dx, dy)
    }
  }

}
