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

class AsCouples : Action {

  override var level: LevelData { LevelObject.find("a1") }

  //  If the 4-dancer formation is a compact wave or line there isn't
  //  enough room to fit in the corresponding 8-dancer formation
  //  In that case the dancers need to spread out more
  private func compactWaveCorrection(_ ctx:CallContext, _ d:Dancer, _ isBeau:Bool) -> Double {
    if (d.isTidal && d.location.length.isAbout(1.5)) {
      let d2 = ctx.dancerToLeft(d) ?? ctx.dancerToRight(d)
      if (d2 != nil && d2!.location.length.isAbout(0.5)) {
        return ((d.angleToOrigin > 0) ^ isBeau) ? 1.5 : -1.5
      }
    }
    else if (d.isTidal && d.location.length.isAbout(0.5)) {
      if (ctx.dancerToLeft(d)?.location.length.isApprox(1.5) == true ||
          ctx.dancerToRight(d)?.location.length.isApprox(1.5) == true) {
        return ((d.angleToOrigin > 0) ^ isBeau) ? 0.5 : -0.5
      }
    }
    return 0.0
  }

  //  Compute location for a dancer of the couple at a specific beat
  //  given location of the single dancer
  private func computeLocation(_ m:Movement, _ beat:Double, _ offset:Double, _ isBeau:Bool) -> Vector {
    let pos = m.translate(beat).location
    let ang = m.rotate(beat).angle
    let v = Vector(offset,0.0).rotate(ang).rotate(isBeau ? .pi/2.0 : -.pi/2.0)
    return pos + v
  }

  //  Return offset of one of the original dancers of the couple
  //  given location of the single dancer
  //  Only used for the very start and very end of the call
  private func coupleDancerOffset(_ d:Dancer, _ isBeau:Bool) -> Vector {

    //  If on axis then each dancer is offset equally from the single dancer
    if (d.isOnXAxis || d.isOnYAxis) {
      let offset = d.isTidal ? 0.5 : 1.0
      return Vector(offset, 0.0).rotate(d.angleFacing).rotate(isBeau ? .pi / 2.0 : -.pi / 2.0)

      //  Not on axis - inside dancer is at same position as single dancer,
      //  outside dancer is 2 units away
    } else {
      let offset = 2.0
      let v = Vector(offset, 0.0).rotate(d.angleFacing).rotate(isBeau ? .pi / 2.0 : -.pi / 2.0)
      return ((d.location + v).length > d.location.length + 0.5) ? v : Vector()
    }
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Build a new context with one dancer from each couple
    //  Start with the beau of each couple
    let beaus = try ctx.dancers.filter { d in
      guard let d2 = d.data.partner else {
        throw CallError("No partner for \(d)")
      }
      if (!ctx.isInCouple(d,d2)) {
        throw CallError("\(d) and \(d2) are not a Couple")
      }
      return d.data.beau
    }
    let dancers = beaus.map { d -> Dancer in
      let d2 = d.data.partner!
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
      //  If couple is straddling an axis, put single dancer on axis
      if (d.location.length.isAbout(d2.location.length)) {
        newpos = (d.location + d2.location).scale(0.5, 0.5)
      }
      //  If couple is on axis, probably tidal formation
      //  put single dancer in between
      else if (d.isTidal && d2.isTidal) {
        newpos = (d.location + d2.location).scale(0.5, 0.5)
      }
      //  Otherwise set to position of the two dancers nearest origin
      else if (d.location.length < d2.location.length) {
        newpos = d.location
      }
      dsingle.setStartPosition(newpos.x, newpos.y)
      return dsingle
    }
    let singlectx = CallContext(dancers)

    //  Perform the As Couples call
    try singlectx.applyCalls(name.lowercased().replaceAll("as\\W+couples\\W+",""))

    //  Get the paths and apply to the original dancers
    singlectx.dancers.forEach { sd in
      let d1q = ctx.dancers.first { $0.number == sd.number && $0.data.beau }
      let d2q = d1q?.data.partner
      guard let d1 = d1q, let d2 = d2q else { return }
      //  Compute movement for each couple dancer for each movement
      //  based on the single dancer
      var sdbeat = 0.0
      sd.path.movelist.enumerated().forEach { (i,m) in
        [true,false].forEach { isBeau in
          //  Get the start and end offsets for the couple dancer
          //  Start and end offsets for the very start and very end
          //  are returned by coupleDancerOffset()
          //  Other offsets are always 0.5 (dancers close together)
          //  with additional correction as needed for compact line/wave formation
          singlectx.animate(sdbeat)
          let start = (i == 0)
            ? coupleDancerOffset(sd, isBeau).length
            : 0.5 + compactWaveCorrection(singlectx, sd, isBeau)
          singlectx.animate(sdbeat + m.beats)
          let end = (i == sd.path.movelist.count - 1)
            ? coupleDancerOffset(sd, isBeau).length
            : 0.5 + compactWaveCorrection(singlectx, sd, isBeau)
          //  Get the 4 points needed to compute Bezier curve
          let cp1 = computeLocation(m, 0.0, start, isBeau)
          let cp2 = computeLocation(m, m.beats / 3.0, start * 2.0 / 3.0 + end / 3.0, isBeau) - cp1
          let cp3 = computeLocation(m, m.beats * 2.0 / 3.0, start / 3.0 + end * 2.0 / 3.0, isBeau) - cp1
          let cp4 = computeLocation(m, m.beats, end, isBeau) - cp1
          //  Now we can compute the Bezier
          let cb = Bezier.fromPoints(Vector(), cp2, cp3, cp4)
          //  And use it to build the Movement
          let cm = Movement(fullbeats:m.beats,
            hands:Hands(rawValue:m.hands.rawValue | ( isBeau ? Hands.RIGHTHAND.rawValue : Hands.LEFTHAND.rawValue))!,
            btranslate: cb, brotate:m.brotate)
          //  And add the Movement to the Path
          if (isBeau) {
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
