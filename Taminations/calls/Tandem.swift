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

class Tandem : Action {

  override var level: LevelData { LevelObject.find("c1") }

  //  Compute location for a dancer of the couple at a specific beat
  //  given location of the single dancer
  private func computeLocation(_ m:Movement, _ beat:Double, _ offset:Double, _ isBeau:Bool) -> Vector {
    let pos = m.translate(beat).location
    let ang = m.rotate(beat).angle
    let v = Vector(offset,0.0).rotate(ang).rotate(isBeau ? 0.0 : .pi)
    return pos + v
  }

  //  Return offset of one of the original dancers of the tandem
  //  given location of the single dancer
  //  Only used for the very start and very end of the call
  private func tandemDancerOffset(_ d:Dancer, _ isLeader:Bool, _ dist:Double) -> Vector {
    //  If on axis then each dancer is offset equally from the single dancer
    if (d.isOnXAxis || d.isOnYAxis) {
      let offset = dist
      return Vector(offset, 0.0).rotate(d.angleFacing).rotate(isLeader ? 0.0 : .pi)
    } else {
      //  Not on axis - inside dancer is at same position as single dancer,
      //  outside dancer is 2 units away
      let offset = 2.0
      let v = Vector(offset, 0.0).rotate(d.angleFacing).rotate(isLeader ? 0.0: .pi)
      return ((d.location + v).length > d.location.length + 0.5) ? v : Vector()
    }
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Build a new context with one dancer from each couple
    //  Start with the Leader of each couple
    let leaders = ctx.dancers.filter { d in d.data.leader }
    let dancers = leaders.map { d -> Dancer in
      let d2 = ctx.dancerInBack(d)!
      //  Select the gender for the single dancer
      var g = Gender.NONE.rawValue
      if (d.gender == Gender.BOY && d2.gender == Gender.BOY) {
        g = Gender.BOY.rawValue
      } else if (d.gender == Gender.GIRL && d2.gender == Gender.GIRL) {
        g = Gender.GIRL.rawValue
      }
      //  Select the couple number for the single dancer
      //  Needed for e.g. As Couples Heads Run
      var nc = "0"
      if (d.number_couple + d2.number_couple).matches("[13]{2}") {
        nc = "1"
      } else if (d.number_couple + d2.number_couple).matches("[24]{2}") {
        nc = "2"
      }
      //  Create the single dancer
      let dsingle = Dancer(d, number_couple:nc, gender:g)
      //  Set the location of the single dancer
      var newpos = d2.location
      //  If tandem is straddling an axis, put single dancer on axis
      if (d.location.length.isAbout(d2.location.length)) {
        newpos = (d.location + d2.location).scale(0.5, 0.5)
      }
      //  If tandem is on axis (uncommon), probably tight column formation
      //  put single dancer in between
      else if (d.isOnAxis && d2.isOnAxis) {
        newpos = (d.location + d2.location).scale(0.5, 0.5)
      }
      //  Otherwise set to position of the two dancers nearest origin
      else if (d.location.length < d2.location.length) {
        newpos = d.location
      }
      dsingle.setStartPosition(newpos.x, newpos.y)
      return dsingle
    }
    if (dancers.count != ctx.dancers.count/2) {
      throw CallError("Unable to group all dancers in Tandems")
    }
    let singlectx = CallContext(dancers)

    //  Perform the Tandem call
    try singlectx.applyCalls(name.lowercased().replaceAll("tandem\\W+",""))

    //  Get the paths and apply to the original dancers
    singlectx.dancers.forEach { sd in
      let d1q = ctx.dancers.first { $0.number == sd.number && $0.data.leader }
      guard let d1 = d1q else { return }
      let d2q = ctx.dancerInBack(d1)
      guard let d2 = d2q else { return }
      //  Compute movement for each tandem dancer for each movement
      //  based on the single dancer
      var sdbeat = 0.0
      sd.path.movelist.enumerated().forEach { (i,m) in
        [true,false].forEach { isLeader in
          //  Get the start and end offsets for the tandem dancer
          //  Start and end offsets for the very start and very end
          //  are returned by tandemDancerOffset()
          //  Other offsets are always 0.5 (dancers close together)
          singlectx.animate(sdbeat)
          let dist = d1.distanceTo(d2)/2.0
          let start = (i == 0)
            ? tandemDancerOffset(sd, isLeader, dist).length
            : 0.5
          singlectx.animate(sdbeat + m.beats)
          let end = (i == sd.path.movelist.count - 1)
            ? tandemDancerOffset(sd, isLeader, dist).length
            : 0.5
          //  Get the 4 points needed to compute Bezier curve
          let cp1 = computeLocation(m, 0.0, start, isLeader)
          let cp2 = computeLocation(m, m.beats / 3.0, 0.5, isLeader) - cp1
          let cp3 = computeLocation(m, m.beats * 2.0 / 3.0, 0.5, isLeader) - cp1
          let cp4 = computeLocation(m, m.beats, end, isLeader) - cp1
          //  Now we can compute the Bezier
          let cb = Bezier.fromPoints(Vector(), cp2, cp3, cp4)
          //  And use it to build the Movement
          let cm = Movement(fullbeats:m.beats,
            hands:Hands(rawValue:m.hands.rawValue | ( isLeader ? Hands.RIGHTHAND.rawValue : Hands.LEFTHAND.rawValue))!,
            btranslate: cb, brotate:m.brotate)
          //  And add the Movement to the Path
          if (isLeader) {
            d1.path.add(cm)
          } else {
            d2.path.add(cm)
          }
        }

        sdbeat += m.beats
      }
    }

  }

}
