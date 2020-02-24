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

class GrandSwingThru : Action {

  override var level: LevelData { LevelObject.find("plus") }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Check that we have 6 dancers in a tidal wave
    var count = 0
    try ctx.actives.forEach { d in
      if (ctx.dancersToLeft(d).count + ctx.dancersToRight(d).count == 5) {
        count += 1
        if let d1 = ctx.dancerToLeft(d) {
          if (!ctx.isInWave(d, d1)) {
            throw CallError("Dancers are not in a tidal wave.")
          }
        }
        if let d2 = ctx.dancerToRight(d) {
          if (!ctx.isInWave(d, d2)) {
            throw CallError("Dancers are not in a tidal wave.")
          }
        }
      } else {
        d.data.active = false
      }
    }

    //  Ok, do each part
    if (norm.contains("left")) {
      try ctx.applyCalls("_Grand Swing Left", "_Grand Swing Right")
    } else {
      try ctx.applyCalls("_Grand Swing Right", "_Grand Swing Left")
    }

  }

}

class GrandSwingX : Action {
  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    let dir = norm.endsWith("right") ? "Right" : "Left"
    if let d2 = norm.endsWith("right") ? ctx.dancerToRight(d) : ctx.dancerToLeft(d) {
      //  Distance is likely 1.0 (shoulder to shoulder)
      let dist = d.distanceTo(d2)
      return TamUtils.getMove("Swing \(dir)").scale(dist/2, dist/2)
    }
    //  d2 is null - must be dancer at end not moving for this part
    return TamUtils.getMove("Stand")
  }
}
