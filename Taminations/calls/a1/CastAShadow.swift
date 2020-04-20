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

//  This class is only for the variation "Cast a Shadow, Centers go 3/4"
//  All the normal Cast a Shadow formations are handled in the xml animations
class CastAShadow : Action {

  override var level:LevelData  { LevelObject.find("a1") }
  override var requires:[String] { ["a1/cast_a_shadow"] }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    if (norm.matches("castashadowcenter.*34")) {
      let incenters = ctx.dancers.filter { $0.data.center && $0.data.trailer }
      if (incenters.count != 2) {
        throw CallError("Need exactly 2 trailing centers to go 3/4.")
      }
      try ctx.applyCalls("Cast a Shadow")
      let castdir = (incenters.first!.isCenterLeft) ? "Left" : "Right"
      incenters.forEach { d in
        d.path = TamUtils.getMove("Forward 2") +
          TamUtils.getMove("Cast \(castdir)") +
          TamUtils.getMove("Forward 2")
      }
    } else {
      throw CallError("Improper variation for Cast a Shadow")
    }
  }

}
