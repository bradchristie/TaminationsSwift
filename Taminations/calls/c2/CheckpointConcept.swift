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


class CheckpointConcept : Action {

  override var level: LevelData { LevelObject.find("c2") }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Parse out the two calls
    let match = name.matchWithGroups("Checkpoint (.+) by (.+)")!
    let firstCall = match[1]
    let secondCall = match[2]

    //  Figure out who does the first call
    var centers:[Dancer] = []
    switch (ctx.groupstr) {
      case "2222" : centers = ctx.groups[1] + ctx.groups[2]
      case "242" : centers = ctx.groups[1]
      case "422" : centers = ctx.groups[1]
      case "224" : centers = ctx.groups[1]
      default : throw CallError("Not a valid formation for Checkpoint")
    }
    let ctx1 = CallContext(ctx,centers)

    let ctx2 = CallContext(ctx,ctx.dancers - centers)
    //  Do the first call
    try ctx1.applyCalls("Concentric \(firstCall)").appendToSource()
    //  Slide in the outer 2 if needed
    if (ctx.groups[2].first!.location.length > 4.0) {
      try ctx2.applyCalls("outer 2 slide in")
    }
    //  Do the second call
    try ctx2.applyCalls(secondCall).appendToSource()
  }

}
