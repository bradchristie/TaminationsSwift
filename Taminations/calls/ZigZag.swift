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

class ZigZag : Action {

  override var level:LevelData { return LevelObject.find("a2") }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    if (d.data.leader && norm.matches("zigz[ai]g")) {
      return TamUtils.getMove("Quarter Right")
    } else if (d.data.leader && norm.matches("zagz[ai]g")) {
      return TamUtils.getMove("Quarter Left")
    } else if (d.data.trailer && norm.matches("z[ai]gzig")) {
      return TamUtils.getMove("Quarter Right")
    } else if (d.data.trailer && norm.matches("z[ai]gzag")) {
      return TamUtils.getMove("Quarter Left")
    } else {
      return TamUtils.getMove("Stand")
    }
  }

}
