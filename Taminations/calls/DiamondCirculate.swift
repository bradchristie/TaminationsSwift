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


class DiamondCirculate : Action {

  override var level: LevelData { LevelObject.find("plus") }

  init() {
    super.init("Diamond Circulate")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    if (ctx.actives.count != 4) {
      throw CallError("Unable to calculate Diamond Circulate")
    }
    try super.perform(ctx, index)
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    //  Should be exactly 1 other active dancer
    //  in front of this dancer within 90 degrees
    let offset = 0.5
    let others = ctx.actives.filter {
        $0 != d
      }.filter { d2 in
        let a = d.angleToDancer(d2).abs
        return !a.isAround(.pi / 2) && a < .pi / 2
      }
    if (others.count != 1) {
      throw CallError("Cannot figure out how dancer \(d) can Diamond Circulate")
    }
    let d2 = others.first!
    let a2 = d.angleToDancer(d2)
    if (a2.isAround(0.0)) {
      throw CallError("Doesn't look like dancer \(d) is in a Diamond")
    }
    let dist = d.distanceTo(d2)
    let isLeft = a2 > 0
    let xScale = dist * cos(a2)
    let yScale = dist * sin(a2)
    let move = (isLeft) ? "Lead Left" : "Lead Right"
    let simplePath = TamUtils.getMove(move).scale(xScale, yScale.abs).changebeats(2.0)
    let isFacing = d2.angleToDancer(d).abs < .pi / 2
    if (isFacing) {
      //  Calculate curves to pass right shoulders
      let bzrot = simplePath.movelist.first!.brotate
      let p2 = Vector(xScale, yScale)
      if (isLeft) {
        let cx1 = xScale * sin(.pi / 6) - offset * sin(.pi / 6)
        let cy1 = yScale - yScale * cos(.pi / 6) + offset * cos(.pi / 6)
        let cx2 = xScale * sin(.pi / 3) - offset * sin(.pi / 3)
        let cy2 = yScale - yScale * cos(.pi / 3) + offset * cos(.pi / 3)
        let bz = Bezier.fromPoints(Vector(), Vector(cx1, cy1), Vector(cx2, cy2), p2)
        let m = Movement(fullbeats: 2.0, hands: Hands.NOHANDS, btranslate: bz, brotate: bzrot)
        return Path(m)
      } else {
        let cx1 = xScale * sin(.pi / 6) + offset * sin(.pi / 6)
        let cy1 = yScale - yScale * cos(.pi / 6) + offset * cos(.pi / 6)
        let cx2 = xScale * sin(.pi / 3) + offset * sin(.pi / 3)
        let cy2 = yScale - yScale * cos(.pi / 3) + offset * cos(.pi / 3)
        let bz = Bezier.fromPoints(Vector(), Vector(cx1, cy1), Vector(cx2, cy2), p2)
        let m = Movement(fullbeats: 2.0, hands: Hands.NOHANDS, btranslate: bz, brotate: bzrot)
        return Path(m)
      }
    }
    return simplePath
  }

}
