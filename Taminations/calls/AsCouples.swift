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

class AsCouples : FourDancerConcept {

  override var level: LevelData { LevelObject.find("a1") }
  override var conceptName: String { "As Couples" }

  //  Build list of (beau, belle) couples
  override func dancerGroups(_ ctx: CallContext) throws -> [[Dancer]] {
    try ctx.dancers.filter { $0.data.beau } .map { d in
        guard let d2 = d.data.partner else {
          throw CallError("No partner for \(d)")
        }
        if (!ctx.isInCouple(d,d2)) {
          throw CallError("\(d) and \(d2) are not a Couple")
        }
        return [d,d2]
    }
  }

  override func startPosition(_ group: [Dancer]) -> Vector {
    let (d, d2) = (group[0], group[1])
    if (d.location.length.isAbout(d2.location.length)) {
      return (d.location + d2.location).scale(0.5, 0.5)
    }
    //  If couple is on axis, probably tidal formation
    //  put single dancer in between
    else if (d.isTidal && d2.isTidal) {
      return (d.location + d2.location).scale(0.5, 0.5)
    }
    //  Otherwise set to position of the two dancers nearest origin
    else if (d.location.length < d2.location.length) {
      return d.location
    } else {
      return d2.location
    }
  }

  override func computeLocation(_ d: Dancer, _ m: Movement, _ beat: Double, _ groupIndex: Int) -> Vector {
    //  Position tandem dancers 0.5 units left and right of the concept dancer
    let pos = m.translate(beat).location
    let offset = 0.5
    let isBeau = groupIndex == 0
    let ang = m.rotate(beat).angle
    let v = Vector(offset,0.0).rotate(ang).rotate((isBeau) ? .pi/2.0 : -.pi/2.0)
    return pos + v
  }

  override func postAdjustment(_ ctx: CallContext, _ cd: Dancer, _ group: [Dancer]) {
    //  Add handholds
    zip(group,[Hands.GRIPRIGHT,Hands.GRIPLEFT]).forEach { (d,h) in
      d.path.addhands(h)
    }
  }

}
