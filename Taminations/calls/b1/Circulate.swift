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

class Circulate : Action {

  override var requires: [String] { ["b1/circulate"] }

  init() {
    super.init("Circulate")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  If just 4 dancers, try Box Circulate
    if (ctx.actives.count == 4) {
      if (ctx.actives.all { d in
        d.data.center
      }) {
        do {
          try ctx.applyCalls("box circulate")
        } catch is CallError {
          //  That didn't work, try to find a circulate path for each dancer
          try super.perform(ctx, index)
        }
      } else {
        try super.perform(ctx, index)
      }
    }
    //  If two-faced lines, do Couples Circulate
    else if (ctx.isTwoFacedLines()) {
      try ctx.applyCalls("couples circulate")
    }
    //  If in waves or lines, then do All 8 Circulate
    else if (ctx.isLines()) {
      try ctx.applyCalls("all 8 circulate")
    }
    //  If in columns, do Column Circulate
    //  (if there are 6 dancers, must be 2 columns of 3)
    else if (ctx.isColumns()) {
      try ctx.applyCalls("column circulate")
    }
    else if (ctx.actives.count==6 && ctx.isColumns(3)) {
      try ctx.applyCalls("column circulate")
    }
    //  If none of those, but tBones, or 6 dancers, calculate each path individually
    else if (ctx.actives.count == 6 || ctx.isTBone()) {
      try super.perform(ctx,index)
      if (ctx.isCollision()) {
        throw CallError("Cannot handle dancer collision here.")
      }
    }
    //  Otherwise ... ???
    else {
      throw CallError("Cannot figure out how to Circulate.")
    }
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    //  The "easier" case - 4 dancer in any type of box
    if (ctx.actives.count == 4) {
      if (d.data.leader) {
        //  Find another active dancer in the same line and move to that spot
        if let d2 = ctx.dancerClosest(d, { dx in
          dx.data.active && (dx.isRightOf(d) || dx.isLeftOf(d))
        }) {
          let dist = d.distanceTo(d2)
          //  Pass right shoulders if crossing another dancer
          let xScale = d2.data.leader && d2.isRightOf(d) ? 1 + dist / 3 : dist / 3
          return TamUtils.getMove((d2.isRightOf(d)) ? "Run Right" : "Run Left")
            .scale(xScale, dist / 2).changebeats(4.0)
        }
      } else if (d.data.trailer) {
        //  Looking at active leader?  Then take its place
        //  TODO maybe allow diagonal circulate?
        if let d2 = ctx.dancerInFront(d) {
          if (d2.data.active) {
            let dist = d.distanceTo(d2)
            if (d2.data.leader) {
              return TamUtils.getMove("Forward").scale(dist, 1.0).changebeats(4.0)
            } else {
              //  Facing dancers - pass right shoulders
              return TamUtils.getMove("Extend Left").scale(dist / 2.0, 0.5).changebeats(2.0) +
                TamUtils.getMove("Extend Right").scale(dist / 2.0, 0.5).changebeats(2.0)

            }
          }
        }
      }
    }

    // A little harder - 6 dancers not in columns
    else if (ctx.actives.count == 6) {
      //  If there is a dancer directly or diagonally in front, go there
      let d2q = ctx.dancerClosest(d) {
        $0.data.active && d.angleToDancer($0).abs.isLessThan(.pi/2.0) &&
          !d.angleFacing.isAround($0.angleFacing + .pi)
      }
      if let d2 = d2q {
        let v = d.vectorToDancer(d2)
        if (d.angleFacing.isAround(d2.angleFacing)) {
          return TamUtils.getMove("Extend Left").changebeats(3.0).scale(v.x,v.y)
        }
        else if (d.angleFacing.isAround(d2.angleFacing + .pi/2.0)) {
          return TamUtils.getMove("Lead Left").changebeats(3.0).scale(v.x,v.y)
        }
        else if (d.angleFacing.isAround(d2.angleFacing - .pi/2.0)) {
          return TamUtils.getMove("Lead Right").changebeats(3.0).scale(v.x,-v.y)
        }
        else {
          throw CallError("Unable to calculate Circulate path.")
        }
      } else {  // Otherwise look for a dancer to the side
        let d3q = ctx.dancerClosest(d) {
          $0.data.active && $0.isRightOf(d)
        } ?? ctx.dancerClosest(d) {
          $0.data.active && $0.isRightOf(d)
        }
        if let d3 = d3q {
          let v = d.vectorToDancer(d3)
          return TamUtils.getMove("Run Left").scale(1.0,v.y/2.0)
        } else {
          throw CallError("Unable to calculate Circulate for dancer \(d)")
        }
      }
    }

    //  The harder case - 8 dancers in a t-bone
    else if (ctx.actives.count == 8) {
      //  Column-like dancer
      if (ctx.dancersInFront(d).count + ctx.dancersInBack(d).count == 3) {
        if (ctx.dancersInFront(d).count > 0) {
          if (ctx.dancerFacing(d) != nil) {
            return TamUtils.getMove("Extend Left").scale(1.0,0.5).changebeats(2.0) +
              TamUtils.getMove("Extend Right").scale(1.0,0.5).changebeats(2.0)
          } else {
            return TamUtils.getMove("Forward 2").changebeats(4.0)
          }
        }
        else if (ctx.dancersToLeft(d).count == 1 && ctx.isFacingSameDirection(d, ctx.dancerToLeft(d)!)) {
          return TamUtils.getMove("Flip Left").changebeats(4.0)
        }
        else if (ctx.dancersToLeft(d).count == 1) {
          return  TamUtils.getMove("Run Left").changebeats(4.0)
        }
        else if (ctx.dancersToRight(d).count == 1) {
          return TamUtils.getMove("Run Right").changebeats(4.0)
        } else {
          throw CallError("Could not calculate Circulate for dancer \(d)")
        }
      }
      //  Line-like dancer
      else if (ctx.dancersToLeft(d).count + ctx.dancersToRight(d).count == 3) {
        if (ctx.dancersInFront(d).count == 1) {
          if (ctx.dancerFacing(d) != nil) {
            return TamUtils.getMove("Extend Left").scale(1.0,0.5).changebeats(2.0) +
                   TamUtils.getMove("Extend Right").scale(1.0,0.5).changebeats(2.0)
          } else {
            return TamUtils.getMove("Forward 2").changebeats(4.0)
          }
        }
        switch (ctx.dancersToLeft(d).count) {
          case 0:
            let d2 = ctx.dancersToRight(d).last!
            if (ctx.isFacingSameDirection(d, d2)) {
              return TamUtils.getMove("Run Right").scale(3.0,3.0).changebeats(4.0)
            } else {
              return TamUtils.getMove("Run Right").scale(2.0, 3.0).changebeats(4.0)
            }
          case 1:
            return  TamUtils.getMove("Run Right").changebeats(4.0)
          case 2:
            if (ctx.isFacingSameDirection(d, ctx.dancerToLeft(d)!)) {
              return TamUtils.getMove("Flip Left").changebeats(4.0)
            } else {
              return TamUtils.getMove("Run Left").changebeats(4.0)
            }
          case 3:
            return TamUtils.getMove("Run Left").scale(2.0,3.0).changebeats(4.0)
          default:
            throw CallError("Could not calculate Circulate for dancer \(d)")
        }

      }
    }

    throw CallError("Cannot figure out how to Circulate.")
  }

}
