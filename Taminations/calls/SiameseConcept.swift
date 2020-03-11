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

class SiameseConcept : FourDancerConcept {

  override var level: LevelData { LevelObject.find("c1") }
  override var conceptName: String { "Siamese" }

  var couples:[[Dancer]] = [[]]
  var tandems:[[Dancer]] = [[]]

  override func dancerGroups(_ ctx: CallContext) throws -> [[Dancer]] {
    //  First find couples
    couples = ctx.dancers.filter { d in
      d.data.beau && (d.data.partner?.data.belle ?? false) }
      .map { d in [d,d.data.partner!] }
    //  Remaining dancers are tandems
    tandems = ctx.dancers.filter { d in
      let d2 = ctx.dancerInBack(d)
      return d2 != nil &&
        couples.flatMap { $0 } .none { [d,d2].contains($0) } }
    .map { d in [d,ctx.dancerInBack(d)!]}
    //  Better be all the dancers
    if ((couples + tandems).flatMap { $0 }.count != ctx.dancers.count) {
      throw CallError("Unable to find all Siamese pairs")
    }
    return couples + tandems
  }

  override func startPosition(_ group: [Dancer]) -> Vector {
    return (group[0].location + group[1].location).scale(0.5,0.5)
  }

  override func computeLocation(_ d: Dancer, _ m: Movement, _ beat: Double, _ groupIndex: Int) -> Vector {
    let pos = m.translate(beat).location
    let offset = 0.5
    let isFirst = groupIndex == 0
    let isCouple = couples.flatMap{$0}.contains(d)
    let ang = m.rotate(beat).angle
    var ang2:Double = .pi
    if (isCouple && isFirst) { ang2 = .pi/2.0 }
    else if (isCouple) { ang2 = -.pi/2.0 }
    else if (isFirst) { ang2 = 0.0 }
    let v = Vector(offset,0.0).rotate(ang).rotate(ang2)
    return pos + v
  }

  override func postAdjustment(_ ctx: CallContext, _ cd: Dancer, _ group: [Dancer]) {
    if (tandems.contains(group)) {
      //  If there is space, spread out the tandem a bit
      let (leader,trailer) = (group[0],group[1])
      if ((ctx.dancerInFront(leader)?.distanceTo(leader) ?? 2.0) > 1.0 &&
        (ctx.dancerInBack(trailer)?.distanceTo(trailer) ?? 2.0) > 1.0) {
        leader.path.skewFromEnd(0.5, 0.0)
        trailer.path.skewFromEnd(-0.5, 0.0)
      }
    } else {  //  Couples
      zip(group,[Hands.GRIPRIGHT,Hands.GRIPLEFT]).forEach { (d,h) in
        d.path.addhands(h)
      }
    }
  }

}
