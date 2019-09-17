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

private extension Dancer {

  func isIn(_ ctx:CallContext) -> Bool {
    return ctx.actives.map { $0.number }.contains(number)
  }
  
}

class WalkandDodge : Action {

  override var level:LevelData { return LevelObject.find("ms") }

  private var walkctx = CallContext([])
  private var dodgectx = CallContext([])
  
  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Figure out who is a walker and who is a dodger.
    //  Save the results in call contexts
    walkctx = CallContext(ctx)
    walkctx.analyze()
    dodgectx = CallContext(ctx)
    dodgectx.analyze()
    var (walkers, dodgers) = ("trailers", "leaders")
    if let groups = name.lowercased().matchWithGroups("(.+) walk(?: and)? (.+) dodge") {
      walkers = groups[1]
      dodgers = groups[2]
    }
    try walkers.split().forEach { it in
      try CodedCall.getCodedCall(it)?.performCall(walkctx)
    }
    try dodgers.split().forEach { it in
      try CodedCall.getCodedCall(it)?.performCall(dodgectx)
    }
    //  If dancer is not in either set then it is inactive
    ctx.dancers.forEach { d in
      d.data.active = d.isIn(walkctx) || d.isIn(dodgectx)
    }
    try super.perform(ctx, index)
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    if (d.isIn(dodgectx)) {
      //  A Dodger.  Figure out which way to dodge.
      var dir = ""
      if (d.data.beau && ctx.dancerToRight(d)?.isIn(walkctx) ?? false) {
        dir = "Right"
      } else if (d.data.belle && ctx.dancerToLeft(d)?.isIn(walkctx) ?? false ) {
        dir = "Left"
      } else if (ctx.dancerToRight(d)?.isIn(walkctx) ?? false) {
        dir = "Right"
      } else if (ctx.dancerToLeft(d)?.isIn(walkctx) ?? false ) {
        dir = "Left"
      } else if (d.data.beau) {
        dir = "Right"
      } else if (d.data.belle) {
        dir = "Left"
      } else {
        throw CallError("Dancer \(d) does not know which way to Dodge")
      }
      if (ctx.isInCouple(d) && d.data.partner!.isIn(dodgectx)) {
        throw CallError("Dodgers would cross each other")
      }
      let dist = d.distanceTo(d.data.partner!)
      return TamUtils.getMove("Dodge \(dir)").scale(1.0,dist/2.0)
      
    } else if (d.isIn(walkctx)) {
      //  A Walker.  Check formation and distance.
      let d2 = ctx.dancerInFront(d)
      if (d2 == nil || (ctx.dancerFacing(d) == d2 && d2!.isIn(walkctx))) {
        throw CallError("Walkers cannot face each other")
      }
      else {
        let dist = d.distanceTo(d2!)
        return TamUtils.getMove("Forward").scale(dist, 1.0).changebeats(3.0)
      }      
    } else {
      throw CallError("Dancer \(d) cannot Walk or Dodge")
    }
  }
  
}
