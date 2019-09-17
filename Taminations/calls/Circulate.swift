/*

  Taminations Square Dance Animations
  Copyright (C) 2019 Brad Christie

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

  override var requires: [String] { return ["b1/circulate"] }

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
    else if (ctx.isColumns()) {
      try ctx.applyCalls("column circulate")
    }
    //  Otherwise ... ???
    else {
      throw CallError("Cannot figure out how to Circulate.")
    }
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    if (d.data.leader) {
      //  Find another active dancer in the same line and move to that spot
      if let d2 = ctx.dancerClosest(d, { dx in
        dx.data.active && (dx.isRightOf(d) || dx.isLeftOf(d))
      }) {
        let dist = d.distanceTo(d2)
        //  Pass right shoulders if crossing another dancer
        let xScale = d2.data.leader && d2.isRightOf(d) ? 1+dist/3 : dist/3
        return TamUtils.getMove((d2.isRightOf(d)) ? "Run Right" : "Run Left")
          .scale(xScale, dist/2).changebeats(4.0)
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
            return TamUtils.getMove("Extend Left").scale(dist/2.0,0.5).changebeats(2.0) +
                   TamUtils.getMove("Extend Right").scale(dist/2.0,0.5).changebeats(2.0)

          }
        }
      }
    }
    throw CallError("Cannot figure out how to Circulate.")
  }

}
