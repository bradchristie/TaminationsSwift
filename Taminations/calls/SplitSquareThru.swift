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

class SplitSquareThru : Action {

  override var level:LevelData { return LevelObject.find("a1") }
  override var requires:[String] { return ["b1/pass_thru","a1/quarter_in","b1/square_thru","b1/face",
                                           "b2/ocean_wave","plus/explode_the_wave","b1/step_thru"] }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    if (ctx.actives.count < 8) {
      throw CallError("Use Heads Start or Sides Start Split Square Thru")
    }
    let (left,right) = norm.startsWith("left") ? ("","Left") : ("Left","")
    let count = Int(norm.suffix(1)) ?? 4
    //  If the centers start, they need to face out to work with the ends
    //  Otherwise they will face in to work with the other dancers
    let face = (ctx.actives.all { d in d.data.center || (ctx.dancerFacing(d) == nil) })
      ? "Out" : "In"
    try ctx.applyCalls("Facing Dancers \(right) Pass Thru and Face \(face)",
                       "\(left) Square Thru \(count-1)")
  }

}

class HeadsStart : Action {

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    if (norm.startsWith("head")) {
      try ctx.applyCalls("Heads Start")
    } else {
      try ctx.applyCalls("Sides Start")
    }
    try ctx.applyCalls(norm.replaceIgnoreCase("(head|side)(s)?\\s+start(a)?\\s+",""))
  }

}