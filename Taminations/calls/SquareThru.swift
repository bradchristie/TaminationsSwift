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

class SquareThru : Action {

  override var requires:[String] { return ["b2/ocean_wave","plus/explode_the_wave","b1/step_thru"] }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Set up alternating hands
    let (left,right) = (norm.startsWith("left"))
      ? ("","Left-Hand")
      : ("Left-Hand","")
    //  Find out how many hands
    let count = Int(norm.suffix(1)) ?? 4
    //  First hand is step to a wave if not already there
    if (ctx.actives.any { d in ctx.isInCouple(d) }) {
      try ctx.applyCalls("Facing Dancers Step to a Compact \(right) Wave")
      ctx.analyze()
    }
    //  Check that wave is the correct hand
    if (ctx.actives.any { d in
      (!d.data.belle && left == "") ||
      (!d.data.beau && right == "") ||
      !ctx.isInWave(d)  }) {
      throw CallError("Cannot \(name) from this formation")
    }
    //  Square thru remaining hands
    try (1 ..< count).forEach { c in
      let hand = (c % 2 == 0) ? right : left
      try ctx.applyCalls("Explode and Step to a Compact \(hand) Wave")
    }
    try ctx.applyCalls("Step Thru")
  }
}

class StepToACompactWave : Action {

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    guard let d2 = ctx.dancerFacing(d) else {
      throw CallError("Cannot find dancer facing \(d)")
    }
    let dist = d.distanceTo(d2)
    let dir = (norm.contains("left")) ? "Right" : "Left"
    return TamUtils.getMove("Extend \(dir)").scale(dist/2,0.5)    
  }

  override func postProcess(_ ctx: CallContext, _ index: Int) {
    //  Do not snap to formation, which parent does
  }

}