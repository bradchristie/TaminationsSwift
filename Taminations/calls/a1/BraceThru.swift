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

class BraceThru : Action {

  override var level:LevelData { LevelObject.find("a1") }
  override var requires:[String] {
    ["b1/pass_thru","b1/courtesy_turn","b1/turn_back","b2/wheel_around"]
  }

  init() {
    super.init("Brace Thru")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    try ctx.subContext(ctx.actives) { ctx2 in
      try ctx2.applyCalls("Pass Thru")
      ctx2.analyze()
      try ctx2.dancers.forEach { d in
        guard let partner = d.data.partner else {
          throw CallError("Dancer \(d) cannot Brace Thru")
        }
        if (d.gender == partner.gender) {
          throw CallError("Same-sex dancers cannot Brace Thru")
        }
      }
      let normal = ctx2.actives.filter {
        $0.data.beau ^ ($0.gender == Gender.GIRL)
      }
      let sashay = ctx2.actives.filter {
        $0.data.beau ^ ($0.gender == Gender.BOY)
      }
      if (normal.count > 0) {
        try ctx2.subContext(normal) {
          try $0.applyCalls("Courtesy Turn")
        }
      }
      if (sashay.count > 0) {
        try ctx2.subContext(sashay) {
          try $0.applyCalls("Turn Back")
        }
      }
      ctx2.appendToSource()
    }
  }

}
