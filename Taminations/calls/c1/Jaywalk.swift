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

class Jaywalk : Action {

  override var level: LevelData { LevelObject.find("c1") }

  init() {
    super.init("Jaywalk")
  }

  //  Find dancer to Jaywalk with this dancer
  //  Only looks from this dancer's perspective
  //  Returns null if no dancer found or if
  //  cannot decide between two other dancers
  func bestJay(_ ctx: CallContext, _ d: Dancer) -> Dancer? {
    var bestDancer: Dancer? = nil
    var bestDistance = 10.0
    ctx.actives.filter {
      $0 != d
    }.forEach { d2 in
      let a1 = d.angleToDancer(d2)
      let a2 = d2.angleToDancer(d)
      //  Dancers must approx. face each other
      if (a1.abs.isLessThan(.pi / 2) && a2.abs.isLessThan(.pi / 2)) {
        let dist = d.distanceTo(d2)
        if (dist.isApprox(bestDistance)) {
          bestDancer = nil
        } else if (dist < bestDistance) {
          bestDancer = d2
          bestDistance = dist
        }
      }
    }
    return bestDancer
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    //  Find dancer to Jaywalk with
    guard let d2 = bestJay(ctx, d)
      ?? (ctx.actives.filter { d3 in
      bestJay(ctx, d3) == d
    }.first) else {
      throw CallError("Cannot find dancer to Jaywalk with $d")
    }
    //   Calculate Jay path
    let v = d.vectorToDancer(d2)
    let da = d.angleFacing - d2.angleFacing
    if (da.isAround(.pi / 2.0)) {
      return TamUtils.getMove("Lead Left Passing").scale(v.x, v.y)
    } else if (da.isAround(.pi * 3.0 / 2.0)) {
      return TamUtils.getMove("Lead Right Passing").scale(v.x, -v.y)
    }
    return (v.y > 0) ?
      //   Pass right shoulders
      TamUtils.getMove("Extend Left")
        .scale(v.x - 1, v.y)
        .changebeats(v.length.Ceil - 1) +
        TamUtils.getMove("Forward")
      :
      TamUtils.getMove("Forward") +
        TamUtils.getMove("Extend Right")
          .scale(v.x - 1, -v.y)
          .changebeats(v.length.Ceil - 1)
  }

}
