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


class TwistAnything: Action {

  override var level: LevelData { LevelObject.find("c1") }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Get "Anything" call
    let anycall = norm == "twisttheline" ? "Star Thru" :
        //  Be careful to allow e.g. "Twist and Right and Left Thru"
        name.replaceFirst(".*? and ", "")
    //  Centers facing out or in?
    if (ctx.center(4).all { d in d.isFacingOut } ) {
      try ctx.applyCalls("Outer 4 Face In and Step while Center 4 Step Ahead",
        "Outer 4 Trade while Center 4 \(anycall)")
    }
    else if (ctx.center(4).all { d in d.isFacingIn } ) {
      try ctx.applyCalls("Outer 4 Face In and Step while Center 4 Half Step Ahead",
        "Center 4 Trade while Outer 4 \(anycall)")
    } else {
      throw CallError("Centers must face the same direction")
    }
  }
}
