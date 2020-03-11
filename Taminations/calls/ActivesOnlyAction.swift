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

//  For most calls where only some dancers are selected, the other dancers
//  can be ignored.  Removing them from the context, and analyzing what is left,
//  often makes it easier to figure out how to perform the call.
class ActivesOnlyAction : Action {

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    if (ctx.actives.count < ctx.dancers.count) {
      let ctx2 = CallContext(ctx, ctx.actives)
      ctx2.analyze()
      try super.perform(ctx2,index)
    } else {
      try super.perform(ctx,index)
    }
  }

}
