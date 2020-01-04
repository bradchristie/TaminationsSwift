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

class ScootAndRamble : Action {

  override var level:LevelData { return LevelObject.find("c1") }
  override var requires:[String] {
    return ["ms/scoot_back","a2/single_wheel","ms/slide_thru","b1/separate"]
  }

  init() {
    super.init("Scoot and Ramble")
  }

  override func performCall(_ ctx: CallContext, _ index: Int) throws {
    try ctx.applyCalls("Scoot Back","Ramble")
  }

}
