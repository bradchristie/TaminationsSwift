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


class While : Action {

  override func perform(_ ctx: CallContext, _ index: Int) throws {

    //  First strip off extra beats added to the inactive dancers
    ctx.contractPaths()

    //  Use another context to do the rest of the call
    //  Don't add standing beats for the inactive dancers
    //  Otherwise there's a lot of standing around at the end
    let ctx2 = CallContext(ctx,beat:0.0).noSnap().noExtend()
    ctx2.dancers.forEach { d in d.data.active = true }
    let whilecall = name.lowercased().replaceFirst("while(\\s+the)?\\s+","")
    //  Strip off standing beats of the inactive dancers
    //  Otherwise there's a lot of standing around at the end
    try ctx2.applyCalls(whilecall)
    ctx2.appendToSource()
  }

}
