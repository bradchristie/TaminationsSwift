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

class Ignore : Action {

  override var level:LevelData { LevelObject.find("c1") }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //   Who should we ignore?
    let query = "ignore (?:the)?((?:\(CodedCall.specifier) )+)(?:and )?(?:for a )?(.+)"
    if let match = name.matchWithGroups(query) {
      let who = match[1]
      let call = match[2]
      //  Remember the dancers that we will ignore
      try ctx.subContext(ctx.dancers) { ctx2 in
        try ctx2.interpretCall(who,noAction:true)
        try ctx2.performCall()
        let ignoreDancers = ctx2.actives
        //  Do the call
        ctx2.dancers.forEach { $0.data.active = true }
        try ctx2.applyCalls(call)
        //  Now erase the action of the ignored dancers
        ctx2.dancers.filter { ignoreDancers.contains($0) }.forEach {
          $0.path = Path()
        }
      }
    }
  }
}
