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

class WheelAnd : Action {

  override var level:LevelData  { return LevelObject.find("c1") }
  override var requires:[String] { return ["c1/wheel_and_anything"] }

  override func performCall(_ ctx: CallContext, _ index: Int) throws {
    let a = name.split("and", maxSplits: 2)
    let (wheelcall, andcall) = (a[0],a[1])
    let reverse = (wheelcall.lowercased().contains("reverse")) ? "Reverse" : ""
    //  Find the 4 dancers to Wheel
    let facingOut = ctx.dancers.filter { d in d.isFacingOut
    }
    if (facingOut.containsAll(ctx.outer(4))) {
      try ctx.applyCalls("Outer 4 \(reverse) Wheel While Center 4 \(andcall)")
    } else if (facingOut.containsAll(ctx.center(4))) {
      try ctx.applyCalls("Center 4 \(reverse) Wheel While Outer 4 Step And \(andcall)")
    } else {
      throw CallError("Unable to find dancers to Wheel")
    }
  }

}
