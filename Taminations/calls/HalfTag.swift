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

class HalfTag : Action {

  override var level:LevelData { LevelObject.find("ms") }
  override var requires:[String] { ["b2/extend","ms/fraction_tag"] }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    let dir = norm.startsWith("left") ? "Left " : ""
    try ctx.applyCalls("\(dir) Quarter Tag","Extend")
  }

}
