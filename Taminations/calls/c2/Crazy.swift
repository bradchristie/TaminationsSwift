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
    let crazy8 = crazycall.matches("counter rotate.*") ? "Split \(crazycall)" :
      crazycall.matches("circulate.*") ? "Split \(crazycall)" : crazycall
    let crazy4 = crazycall.matches("counter rotate.*")
      ? "Center 4 Box \(crazycall)" : "Center 4 \(crazycall)"

    try ctx.applyCalls(norm.contains("reversecrazy") ? crazy4 : crazy8)
    ctx.matchStandardFormation()
    try ctx.applyCalls(norm.contains("reversecrazy") ? crazy8 : crazy4)
    if (!norm.startsWith("12")) {
      ctx.matchStandardFormation()
      try ctx.applyCalls(norm.contains("reversecrazy") ? crazy4 : crazy8)
      if (!norm.startsWith("34")) {
        ctx.matchStandardFormation()
        try ctx.applyCalls(norm.contains("reversecrazy") ? crazy8 : crazy4)
      }
    }

  }
}
