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

class Run : Action {

  override var level: LevelData { LevelObject.find("b2") }

  private func runOne(_ d:Dancer, _ d2:Dancer, _ dir:String) {
    let dist = d.distanceTo(d2)
    d.path.add(TamUtils.getMove("Run \(dir)").scale(1.0,dist/2.0))
    var m2 = "Stand"
    if (d.isRightOf(d2)) { m2 = "Dodge Right" }
    else if (d.isLeftOf(d2)) { m2 = "Dodge Left" }
    else if (d.isInFrontOf(d2)) { m2 = "Forward 2" }
    else if (d.isInBackOf(d2)) { m2 = "Back 2" }
    d2.path.add(TamUtils.getMove(m2).scale(dist/2.0,dist/2.0))
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    var dancersToRun = Set(ctx.dancers.filter { $0.data.active })
    var dancersToWalk = Set(ctx.dancers.filter { !$0.data.active })
    var usePartner = false
    while (!dancersToRun.isEmpty) {
      var foundRunner = false
      try dancersToRun.forEach { d in
        let dleft = ctx.dancerToLeft(d)
        let dright = ctx.dancerToRight(d)
        let isLeft = dleft != nil && dancersToWalk.contains(dleft!) &&
          norm != "runright"
        let isRight = dright != nil && dancersToWalk.contains(dright!) &&
          norm != "runleft"
        if (!isLeft && !isRight) {
          throw CallError("Dancer \(d) cannot Run.")
        }
        else if (!isLeft || (usePartner && dright != nil && dright == d.data.partner)) {
          //  Run Right
          guard let d2 = dright else {
            throw CallError("Dancer \(d) unable to Run.")
          }
          runOne(d,d2,"Right")
          dancersToRun.remove(d)
          dancersToWalk.remove(d2)
          foundRunner = true
          usePartner = false
        }
        else if (!isRight || (usePartner && dleft != nil && dleft == d.data.partner)) {
          //  Run Left
          guard let d2 = dleft else {
            throw CallError("Dancer \(d) unable to Run.")
          }
          runOne(d,d2,"Left")
          dancersToRun.remove(d)
          dancersToWalk.remove(d2)
          foundRunner = true
          usePartner = false
        }
      }
      if (!foundRunner) {
        if (!usePartner) {
          usePartner = true
        } else {
          throw CallError("Unable to calculate \(name) for this formation.")
        }
      }
    }
  }

}
