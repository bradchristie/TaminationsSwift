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

//  This covers both Promenade Home and
//  Swing Your Corner and Promenade
class PromenadeHome : Action {

  var startPoints:[Vector] = []

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    guard ctx.dancers.count == 8 else {
      throw CallError("Only for 4 couples at this point.")
    }
    //  Compute the center point of each couple
    startPoints = [1,2,3,4].map { coupleNumber in
      let couple = ctx.dancers.filter { d in
        if (d.gender == Gender.GIRL && norm.contains("corner")) {
          return (d.number_couple.i % 4) + 1 == coupleNumber
        } else {
          return d.number_couple.i == coupleNumber
        }
      }
      let boy = couple[0]
      let girl = couple[1]
      let center = (boy.location + girl.location) / 2.0
      //  Snap to the nearest axis in the promenade direction
      //  In 1st quadrant, off X-axis -> snap to Y axis
      if (!center.x.isLessThan(0.0) && center.y.isGreaterThan(0.0)) {
        return Vector(0.0,2.0)
        //  2nd quadrant, off Y-axis -> snap to -X axis
      } else if (center.x.isLessThan(0.0) && !center.y.isLessThan(0.0)) {
        return Vector(-2.0,0.0)
        //  3rd quadrant, off X-axis - snap to -Y axis
      } else if (!center.x.isGreaterThan(0.0) && center.y.isLessThan(0.0)) {
        return Vector(0.0,-2.0)
      } else {
        return Vector(2.0,0.0)
      }
    }
    //  Should be one couple at each axis point
    if (startPoints.reduce(Vector()) { a,b in a + b } != Vector()) {
      throw CallError("Dancers not positioned properly for Promenade.")
    }
    //  Check that dancers are in sequence
    try startPoints.enumerated().forEach { i2, v in
      let a1 = v.angle
      let a2 = startPoints[(i2+1) % 4].angle
      let adiff = a2.angleDiff(a1)
      if (!adiff.angleEquals(.pi/2.0)) {
        throw CallError("Dancers are not resolved, cannot promenade home.")
      }
    }
    //  Now get each dancer to move to the calculated promenade position
    try super.perform(ctx, index)
    //  Promenade to home
    repeat {
      try ctx.applyCalls("Counter Rotate")
    } while (ctx.dancers[0].path.movelist.count < 10 &&
             !ctx.dancers[0].anglePosition.angleEquals(.pi))
    //  Adjust to squared set
    try ctx.applyCalls("Half Wheel Around")
    ctx.level = LevelObject.find("b1")  //  otherwise Counter Rotate would set level to C-1
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    let num = (d.gender == Gender.GIRL && norm.contains("corner"))
      ? (d.number_couple.i % 4) + 1 : d.number_couple.i
    let startCouple = startPoints[num - 1]
    let startLocation = startCouple * ((d.gender == Gender.BOY) ? 1.0 : 1.5)
    let startAngle =
      norm.contains("corner")
        ? (d.gender == Gender.BOY) ? startCouple.angle : startCouple.angle + .pi
        : startCouple.angle + .pi/2.0
    let extraMoves = norm.contains("corner")
      ? TamUtils.getMove("ssqtr") + TamUtils.getMove("ssqtr") +
        TamUtils.getMove("ssqtr") + TamUtils.getMove("ssqtr") +
        TamUtils.getMove((d.gender == Gender.BOY) ? "Quarter Left" : "Quarter Right")
      : Path()
    return ctx.moveToPosition(d,startLocation,startAngle) + extraMoves
  }

}
