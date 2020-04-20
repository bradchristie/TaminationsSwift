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

  override var level:LevelData  { LevelObject.find("c1") }
  override var requires:[String] { ["c1/wheel_and_anything"] }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    let a = name.split("and", maxSplits: 2)
    let (wheelcall, andcall) = (a[0],a[1])
    let reverse = (wheelcall.lowercased().contains("reverse")) ? "Reverse" : ""
    //  Find the 4 dancers to Wheel
    let facingOut = ctx.dancers.filter { d in d.isFacingOut }
    //  Check for t-bones, center 4 facing out, outer 4 facing their shoulders
    if (ctx.center(4).containsAll(facingOut)) {
      try ctx.applyCalls("As Couples Step")
    }
    //  First we will try the usual way
    do {
      try ctx.applyCalls("Outer 4 \(reverse) Wheel While Center 4 \(andcall)")
    } catch let e1 as CallError {
      //  Maybe the call applies to all 8 dancers
      //  (although that really doesn't fit the definition)
      do {
        try ctx.applyCalls("OUter 4 \(reverse) Wheel",andcall)
      } catch _ as CallError {
        //  That didn't work either, throw the original error
        throw e1
      }
    }
  }

}
