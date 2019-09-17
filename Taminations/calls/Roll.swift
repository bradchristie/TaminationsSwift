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

class Roll : Action {

  override var level:LevelData { return LevelObject.find("plus") }

  init() {
    super.init("Roll")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  TODO should also check that there is a preceeding action
    if (index == 0) {
      throw CallError("'and Roll' must follow another call.")
    }
    try super.perform(ctx, index)
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    let roll = ctx.roll(d)
    if (roll.isRight) {
      return TamUtils.getMove("Quarter Right")
    } else if (roll.isLeft) {
      return TamUtils.getMove("Quarter Left")
    }
    return TamUtils.getMove("Stand")
  }

}
