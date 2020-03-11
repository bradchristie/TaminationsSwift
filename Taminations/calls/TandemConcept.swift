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

class TandemConcept: FourDancerConcept {

  override var level: LevelData { LevelObject.find("c1") }
  override var conceptName: String { "Tandem" }

  //  Build list of (leader, trailer) tandems
  override func dancerGroups(_ ctx: CallContext) throws -> [[Dancer]] {
    try ctx.dancers.filter { $0.data.leader } .map { d in
        guard let d2 = ctx.dancerInBack(d) else {
          throw CallError("No tandem for dancer \(d)")
        }
        if (!d2.data.trailer) {
          throw CallError("\(d) and \(d2) are not a Tandem")
        }
        return [d,d2]
      }
  }

  override func startPosition(_ group: [Dancer]) -> Vector {
    let (d, d2) = (group[0], group[1])
    if (d.location.length.isAbout(d2.location.length)) {
      //  If tandem is straddling an axis, put single dancer on axis
      return (d.location + d2.location).scale(0.5, 0.5)
    }
    //  If tandem is on an axis (uncommon), probably tight column formation
    //  put single dancer in between
    else if (d.isOnAxis && d2.isOnAxis) {
      return (d.location + d2.location).scale(0.5, 0.5)
    }
    //  Otherwise set to position of the two dancers nearest origin
    else if (d.location.length < d2.location.length) {
      return d.location
    }
    else {
      return d2.location
    }
  }

  override func computeLocation(_ d: Dancer, _ m: Movement, _ beat: Double, _ groupIndex: Int) -> Vector {
    //  Position tandem dancers 0.5 units in front and behind concept dancer
    let offset = 0.5
    let isLeader = groupIndex == 0
    let pos = m.translate(beat).location
    let ang = m.rotate(beat).angle
    let v = Vector(offset,0.0).rotate(ang).rotate(isLeader ? 0.0 : .pi)
    return pos + v
  }

  override func postAdjustment(_ ctx: CallContext, _ cd: Dancer, _ group: [Dancer]) {
    //  If there is space, spread out the tandem a bit
    let (leader,trailer) = (group[0],group[1])
    if ((ctx.dancerInFront(leader)?.distanceTo(leader) ?? 2.0) > 1.0 &&
      (ctx.dancerInBack(trailer)?.distanceTo(trailer) ?? 2.0) > 1.0) {
      leader.path.skewFromEnd(0.5, 0.0)
      trailer.path.skewFromEnd(-0.5, 0.0)
    }
  }

}
