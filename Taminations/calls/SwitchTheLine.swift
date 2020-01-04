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

class SwitchTheLine : Action {

  override var level: LevelData { LevelObject.find("a2") }

  init() {
    super.init("Switch the Line")
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Start with Ends Cross Run
    try ctx.applyCalls("Ends Cross Run")
    //  And now make tne centers Run instead of Dodge
    ctx.dancers.forEach { $0.animate(beat: 0.0) }
    ctx.dancers.filter { $0.data.center}.forEach { d in
      d.path.clear()
      let d2 = d.data.partner
      if (d2 != nil) {  // better not be
        d.path.add(TamUtils.getMove(d.data.beau ? "Flip Right" : "Flip Left")
        .scale(1.0,d.distanceTo(d2!)/2.0))
      }
    }
  }

}