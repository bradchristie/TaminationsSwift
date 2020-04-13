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

class ConcentricConcept : FourDancerConcept {

  override var level: LevelData { LevelObject.find("c1") }
  override var conceptName: String { "Concentric" }
  private var dancerLocations = Dictionary<String,[Vector]>()
  private var dancerShifts = Dictionary<String,[Vector]>()
  private var mindist = 10.0

  override func dancerGroups(_ ctx: CallContext) throws -> [[Dancer]] {
    ctx.actives.map { d in [d] }
  }

  //  Compute location of "normal" dancer from position of
  //  outer concentric dancer.
  //  This just shifts it in 2 units along the long axis
  override func startPosition(_ group: [Dancer]) -> Vector {
    let loc = group.first!.location
    let shift = min(2.0,mindist-0.5)
    return (loc.x.abs > loc.y.abs)
      ? Vector(loc.x - (shift*loc.x.sign), loc.y)
      : Vector(loc.x, loc.y - (shift*loc.y.sign))
  }

  override func analyzeConceptResult(_ conceptctx: CallContext,
                                     _ realctx: CallContext) {
    //  Look at each movement to figure out
    //  the end point of the real dancer.
    zip(conceptctx.dancers, realctx.dancers).forEach { (cd, d) in
      var cdbeat = 0.0
      let dloc = d.starttx
      var dlocList: [Vector] = []
      var shiftList: [Vector] = []
      dlocList.append(d.location - cd.location)
      cd.path.movelist.enumerated().forEach { (i, m) in
        let isLast = i == cd.path.movelist.count - 1

        //  Does the movement cross an axis?
        //  If so, remember so we can shift the dancer away from that axis
        var (xshift, yshift) = (0.0, 0.0)
        cd.animate(beat: cdbeat)
        let cdloc1 = cd.location
        cd.animate(beat: cdbeat + m.beats)
        let cdloc2 = cd.location
        if (!cdloc1.x.isAbout(0.0) && !cdloc2.x.isAbout(0.0) &&
          cdloc1.x.sign != cdloc2.x.sign) {
          //  Crosses Y axis
          yshift = 1.5
        }
        if (!cdloc1.y.isAbout(0.0) && !cdloc2.y.isAbout(0.0) &&
          cdloc1.y.sign != cdloc2.y.sign) {
          //  Crosses X axis
          xshift = 1.5
        }
        if (xshift != 0.0 || yshift != 0.0) {
          cd.animate(beat: cdbeat + m.beats / 2.0)
          //  If it's already some distance out on the axis don't need to shift
          if (cd.location.length.isLessThan(1.5)) {
            xshift *= cd.location.x.sign
            yshift *= cd.location.y.sign
          } else {
            xshift = 0.0
            yshift = 0.0
          }
          cd.animate(beat: cdbeat + m.beats)
        }
        shiftList.append(Vector(xshift, yshift))

        //  If it ends an axis, then real dancer is on same axis further out
        var (dx, dy) = (0.0, 0.0)
        if (cd.isOnXAxis) {
          dx = 2.0
        } else if (cd.isOnYAxis) {
          dy = 2.0
        } else if (!isLast) {

          //  For 2x2 not at end of call, just shift out both directions
          dx = 2.0
          dy = 2.0
        } else {

          //  Not on an axis (ends in a 2x2) - should we move out X or Y?
          //  If started on an axis (i.e., not a 2x2),
          //  then shift out on the other axis
          if (dloc.location.x.isAbout(0.0)) {
            dx = 2.0
          } else if (dloc.location.y.isAbout(0.0)) {
            dy = 2.0
          } else {

            //  Starts and ends in a 2x2
            //  The rule is "Lines to Lines, Columns to Columns"
            //  Has the dancer's facing direction changed 90 degrees?
            let a1 = dloc.angle
            let a2 = cd.angleFacing
            let is90 = a1.angleDiff(a2).abs.isAround(.pi / 2.0)
            if ((dloc.location.x.abs > dloc.location.y.abs) ^ is90) {
              dx = 2.0
            } else {
              dy = 2.0
            }
          }
        }
        dx *= cd.location.x.sign
        dy *= cd.location.y.sign
        //  Remember the shift, will be used in computeLocation below
        dlocList.append(Vector(dx, dy))

        cdbeat += m.beats
      }
      dancerLocations[cd.number] = dlocList
      dancerShifts[cd.number] = shiftList
    }
  }

  override func computeLocation(_ d: Dancer, _ m: Movement, _ mi: Int, _ beat: Double, _ groupIndex: Int) -> Vector {
    //  Get the offset vectors for the start and end of this movement
    let v1 = dancerLocations[d.number]![mi]
    let v2 = dancerLocations[d.number]![mi+1]
    //  Convert to dancer space
    let v1d = v1.rotate(-d.angleFacing)
    let v2d = v2.rotate(-d.angleFacing)
    //  Compute interpolation fraction
    let f = beat / m.beats
    //  Interpolate each offset to get dancer's current offset
    //  Hack for 1st movement, parent has adjusted according to startPosition
    let vnow = (v2d - v1d) * f + ((mi==0) ? v1d : Vector())
    let pos = m.translate(beat).location
    let shift = (f.isGreaterThan(0.0) && f.isLessThan(1.0))
      ? dancerShifts[d.number]![mi].rotate(-d.angleFacing) : Vector()
    //  And add it to the concept dancer location
    return pos + vnow + shift
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    if (ctx.actives.count == 8) {
      try ctx.applyCalls("Center 4 \(realCall) While Outer 4 \(name)")
    } else if (ctx.dancers.count == 8) {
      try CallContext(ctx,ctx.actives).applyCalls(name).appendToSource()
    } else {
      mindist = ctx.dancers.reduce(10.0) { min($0,$1.location.length)  }
      try super.perform(ctx, index)
    }
  }

}
