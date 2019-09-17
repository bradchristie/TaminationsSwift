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

class Cross : Action {

  override var level:LevelData { return LevelObject.find("a1") }

  var crosscount = 0

  init() {
    super.init("Cross")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  If dancers are not specified, then the trailers cross
    if (ctx.actives.count == ctx.dancers.count) {
      ctx.dancers.forEach { d in d.data.active = d.data.trailer }
    }
    if (ctx.actives.count == ctx.dancers.count || ctx.actives.count == 0) {
      throw CallError("You must specify which dancers Cross.")
    }
    crosscount = 0
    try super.perform(ctx, index)
    if (crosscount == 0) {
      throw CallError("Cannot find dancers to Cross")
    }

  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    //  Find the other dancer to cross with
    var d2:Dancer? = nil
    ctx.actives.forEach { it in
      //  Dancers must be facing opposite directions
      //  and facing diagonal to each other
      let a = d.angleToDancer(it).abs
      if (d.tx.angle.angleDiff(it.tx.angle).abs.isApprox(.pi) &&
        !a.angleEquals(0.0) &&
        !a.angleEquals(.pi/2) &&
        a < .pi/2) {
          if (d2 == nil)  { d2 = it }
          else if (d.distanceTo(d2!).isApprox(d.distanceTo(it))) {
            if (it.location.length > d2!.location.length) {
              d2 = it
            }
          }
          else if (d.distanceTo(it) < d.distanceTo(d2!)) { d2 = it }
      }
    }
    //  OK if some dancers cannot cross
    if (d2 == nil) {
      return Path()
    }
    //  Now compute the X and Y values to travel
    //  The standard has x distance = 2 and y distance = 2
    let a = d.angleToDancer(d2!)
    let dist = d.distanceTo(d2!)
    let x = dist * a.Cos
    let y = dist * a.abs.Sin
    crosscount += 1
    return TamUtils.getMove((a > 0) ? "Cross Left" : "Cross Right").scale(x/2.0,y/2.0)    
  }

}
