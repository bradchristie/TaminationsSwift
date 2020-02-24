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

class VerticalTag : Action {

  override var level: LevelData { LevelObject.find("c1") }
  override var requires:[String] { ["b2/extend"] }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    ctx.analyzeActives()
    //  This calls performOne below, which performs Vertical 1/4 Tag
    try super.perform(ctx, index)
    //  Now extend as requested
    if (norm.contains("12")) {
      try ctx.applyCalls("extend")
    }
    else if (norm.contains("34")) {
     try ctx.applyCalls("extend", "extend")
    }
    else if (!norm.contains("14")) {
     try ctx.applyCalls("extend", "extend", "extend")
    }

  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    guard (d.data.beau || d.data.belle) else {
      throw CallError("Dancer \(d) is not part of a couple")
    }
    guard (d.data.leader || d.data.trailer) else {
      throw CallError("Dancer \(d) is not in a box")
    }
    guard let dp = d.data.partner else {
      throw CallError("Cannot find partner for \(d)")
    }
    guard let dt = (d.data.leader) ? ctx.dancerInBack(d) : ctx.dancerInFront(d) else {
      throw CallError("Cannot find dancer in front or behind \(d)")
    }
    //  Distance from this dancer to center point of box
    let w = d.distanceTo(dp) / 2.0
    let h = d.distanceTo(dt) / 2.0

    if (norm.contains("left")) {
      if (d.data.leader) {
        if (d.data.beau && dp.data.belle) {
          return TamUtils.getMove("Flip Right").skew(-h, 3.0 - w)
        } else if (d.data.belle) {
          return TamUtils.getMove("Flip Left").skew(0.5, w - 2.0)
        } else {
          return TamUtils.getMove("Flip Right").skew(0.5, 2.0 - w)
        }
      } else {  // trailer
        if (d.data.belle && dp.data.beau) {
          return TamUtils.getMove("Dodge Left").changebeats(3.0).skew(-0.5, w - 2.0)
        } else if (d.data.belle) {
          return TamUtils.getMove("Forward").changebeats(3.0).skew(h - 1.0, w - 1.0)
        } else {
          return TamUtils.getMove("Extend Right").changebeats(3.0).skew(h - 1.0, w - 2.0)
        }
      }

    } else {
      if (d.data.leader) {
        //  Leader always goes behind unless belle of a couple facing out
        if (d.data.belle && dp.data.beau) {
          return TamUtils.getMove("Flip Left").skew(-h, w - 3.0)
        } else if (d.data.beau) {
          return TamUtils.getMove("Flip Right").skew(0.5, 2.0 - w)
        } else {
          return TamUtils.getMove("Flip Left").skew(0.5, w - 2.0)
        }
      } else {  // trailer
        //  Trailer always goes in front unless beau of a couple facing in
        if (d.data.beau && dp.data.belle) {
          return TamUtils.getMove("Dodge Right").changebeats(3.0).skew(-0.5, 2.0 - w)
        } else if (d.data.beau) {
          return TamUtils.getMove("Forward").changebeats(3.0).skew(h - 1.0, 1.0 - w)
        } else {
          return TamUtils.getMove("Extend Left").changebeats(3.0).skew(h - 1.0, w)
        }
      }
    }
  }

}
