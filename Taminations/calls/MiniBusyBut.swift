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

class MiniBusyBut : Action {

  override var level:LevelData { LevelObject.find("c1") }
  override var requires: [String] { ["a2/mini_busy"] }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    try ctx.applyCalls("_Mini-Busy But","Center 4 "+norm.replaceAll(".*but",""))
  }
}