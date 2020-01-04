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

class Cloverleaf : Action {

  override var level:LevelData { LevelObject.find("ms") }
  override var requires:[String] {
    ["a1/clover_and_anything","a1/cross_clover_and_anything"] 
  }

  init() {
    super.init("Cloverleaf")
  }

  //  We get here only if standard Cloverleaf with all 8 dancers active fails.
  //  So do a 4-dancer cloverleaf
  override func perform(_ ctx: CallContext, _ index: Int) throws {
    if (ctx.outer(4).all { $0.data.active }) {
      try ctx.applyCalls("Clover and Nothing")
    } else {
    try ctx.applyCalls("Clover and Step")
    }
  }

}

class CloverAnd : Action {

  override var level:LevelData {
    if (name == "Clover and Nothing" || name == "Clover and Step") {
      return LevelObject.find("ms")
    } else {
      return LevelObject.find("a1")
    }
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Find the 4 dancers to Cloverleaf
    //  First check the outer 4
    let outer4 = ctx.dancers.sortedBy { d in d.location.length}.drop(4)
    //  If that fails try for 4 dancers facing out
    let facingOut = ctx.dancers.filter { d in d.isFacingOut }
    var clovers:[Dancer] = []
      //  Don't use outer4 directly, instead filter facingOut
      //  This preserves the original order, required for mapping
      if (facingOut.containsAll(outer4)) {
        clovers = facingOut.filter { d in outer4.contains(d) }
      } else if (facingOut.count == 4) {
        clovers = facingOut
      }  else {
        throw CallError("Unable to find dancers to Cloverleaf")
      }
    //  Make those 4 dancers Cloverleaf
    let split = name.split("and",maxSplits: 2)
    let (clovercall,andcall) = (split[0],split[1])
    let ctx1 = CallContext(ctx,clovers)
    try ctx1.applyCalls("\(clovercall) and")
    //  "Clover and <nothing>" is stored in A-1 but is really Mainstream
    ctx1.level = LevelObject.find("ms")
    ctx1.appendToSource()
    //  And the other 4 do the next call at the same time
    let ctx2 = CallContext(ctx,ctx.dancers.filterNot { d in clovers.contains(d) } )
    ctx2.dancers.forEach { d in d.data.active = true }
    try ctx2.applyCalls(andcall)
    ctx2.appendToSource()
  }

}
