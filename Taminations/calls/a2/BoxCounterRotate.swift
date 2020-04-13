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

class BoxCounterRotate : Action {

  override var level:LevelData { LevelObject.find("a2") }

  init() {
    super.init("Box Counter Rotate")
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    let v = d.location
    let a1 = d.tx.angle
    let a2 = v.angle
    //  Determine if this is a rotate left or right
    let isLeft = a2.angleDiff(a1) < 0
    let v2 = isLeft ? v.rotate(.pi/2) : v.rotate(-.pi/2)
    let cy4 = isLeft ? 0.45 : -0.45
    let y4 = isLeft ? 1.0 : -1.0
    //  Compute the model points
    let dv = (v2 - v).rotate(-a1)
    let cv1 = (v2 * 0.5).rotate(-a1)
    let cv2 = (v * 0.5).rotate(-a1) + dv
    let m = Movement(beats: 2.0, hands: .NOHANDS,
      btranslate: Bezier(x1:0.0, y1:0.0, ctrlx1: cv1.x, ctrly1: cv1.y,
                         ctrlx2: cv2.x, ctrly2: cv2.y, x2: dv.x, y2: dv.y),
      brotate: Bezier(x1:0.0, y1:0.0, ctrlx1: 0.55, ctrly1:0.0,
                      ctrlx2: 1.0, ctrly2: cy4, x2: 1.0, y2: y4))
    return Path(m)
  }
}
