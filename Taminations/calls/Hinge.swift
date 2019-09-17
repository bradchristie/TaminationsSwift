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


class Hinge : Action {

  private var myLevel = LevelObject.find("ms")
  override var level:LevelData { return myLevel }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    //  Find the dancer to hinge with
    let leftCount = ctx.dancersToLeft(d).filter { $0.data.active }.count
    let rightCount = ctx.dancersToRight(d).filter { $0.data.active }.count
    let d2q = leftCount.isOdd && rightCount.isEven ? ctx.dancerToLeft(d)
      : leftCount.isEven && rightCount.isOdd ? ctx.dancerToRight(d)
      : nil
    guard let d2 = d2q else {
      throw CallError("Dancer \(d) has no one to hinge with.")
    }
    if (!ctx.isInWave(d,d2)) {
      myLevel = LevelObject.find("a1")
    }
    let dist = d.distanceTo(d2)
      //  Hinge from mini-wave, left or right handed
    if (ctx.isInWave(d,d2)) {
      return TamUtils.getMove(d2.isRightOf(d) ? "Hinge Right" : "Hinge Left").scale(1.0, dist / 2)
    }
    //  Left Partner Hinge
    if (ctx.isInCouple(d,d2) && d2.isRightOf(d) && name.contains("Left")) {
      return TamUtils.getMove("Quarter Right").skew(-1.0, -1.0 * (dist / 2))
    }
    if (ctx.isInCouple(d,d2) && d2.isLeftOf(d) && name.contains("Left")) {
      return TamUtils.getMove("Lead Left").scale(1.0, dist / 2)
    }
    //  Partner Hinge
    if (ctx.isInCouple(d,d2) && d2.isRightOf(d)) {
      return TamUtils.getMove("Lead Right").scale(1.0, dist / 2)
    }
    if (ctx.isInCouple(d,d2) && d2.isLeftOf(d)) {
      return TamUtils.getMove("Quarter Left").skew(-1.0, dist / 2)
    }
    throw CallError("Dancer \(d) has no one to hinge with.")
  }

}
