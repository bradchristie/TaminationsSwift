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

class BackAway : Action {

  init() {
    super.init("Back Away")
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    if (d.isFacingIn && ctx.dancersInBack(d).count == 0) {
      //  TODO hold hands with partner?
      return TamUtils.getMove("Back 2")
    }
    throw CallError("Dancer \(d) cannot Back Away")    
  }

}
