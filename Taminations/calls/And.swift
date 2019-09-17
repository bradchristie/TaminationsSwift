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

class And : FilterActives {

  init() {
    super.init("and")
  }

  override func performCall(_ ctx: CallContext, _ index: Int) throws {
    if (index < 1) {
      throw CallError("Use \"and\" to combine calls")
    }
    try super.performCall(ctx, index)
  }

  //  If the previous call was retrieved from XML and has a selector
  //  such as Boys or Heads then we need to filter the actives here
  override func isActive(_ d: Dancer, _ ctx: CallContext, _ i: Int) -> Bool {
    var retval = d.data.active
    ctx.callstack.dropLast(ctx.callstack.count - i).forEach { call in
      var prevword = ""
      call.name.split(" ").forEach { it in
        switch (TamUtils.normalizeCall(it)) {
          case "boy": retval = retval && d.gender == Gender.BOY
          case "girl": retval = retval && d.gender == Gender.GIRL
          case "head": retval = retval && d.number_couple.i % 2 == 1
          case "side": retval = retval && d.number_couple.i % 2 == 0
          case "beau": retval = retval && d.data.beau
          case "belle": retval = retval && d.data.belle
          case "center": retval = (prevword == "very") ? retval && d.data.verycenter : retval && d.data.center
          case "end": retval = retval && d.data.end
          case "lead": retval = retval && d.data.leader
          case "trail": retval = retval && d.data.trailer
          default: break
        }
        prevword = it.lowercased()
      }
    }
    return retval
  }

}
