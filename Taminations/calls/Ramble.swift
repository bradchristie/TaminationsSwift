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

class Ramble : Action {

  override var level:LevelData { return LevelObject.find("c1") }
  override var requires:[String] {
    return ["a2/single_wheel","ms/slide_thru","b1/separate"]
  }

  init() {
    super.init("Ramble")
  }
  override func performCall(_ ctx: CallContext, _ index: Int) throws {
    let ctx2 = CallContext(ctx,beat:0.0).noSnap().noExtend()
    try ctx2.applyCalls("Center 4 Single Wheel and Slide Thru")
    try ctx2.applyCalls("Outer 4 Separate and Slide Thru")
    ctx2.appendToSource()
  }

}
