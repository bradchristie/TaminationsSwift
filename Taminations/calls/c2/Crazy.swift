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

class Crazy : Action {

  override var level:LevelData { LevelObject.find("c2") }
  override var requires:[String] { ["a2/box_counter_rotate",
                                    "a2/split_counter_rotate",
                                    "b1/circulate"] }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    let crazycall = name.lowercased().replaceAll(".*crazy", "")
    var crazy8 = ""
    var crazy4 = ""
    if (crazycall.lowercased().matches("\\s*counter rotate.*")) {
      crazy8 = "Split"
      crazy4 = "Box"
    } else if (crazycall.lowercased().matches("\\s*circulate.*")) {
      crazy8 = "Split"
    }
    try ctx.applyCalls("\(crazy8) \(crazycall)","Center 4 \(crazy4) \(crazycall)")
    if (!norm.startsWith("12")) {
      ctx.matchStandardFormation()
      try ctx.applyCalls("\(crazy8) \(crazycall)")
      if (!norm.startsWith("34")) {
        try ctx.applyCalls("Center 4 \(crazy4) \(crazycall)")
      }
    }

  }
}
