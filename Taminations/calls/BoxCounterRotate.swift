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

  override var level:LevelData { return LevelObject.find("a2") }

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
    let m = Movement(fullbeats: 2.0, hands: .NOHANDS,
      cx1: cv1.x, cy1: cv1.y, cx2: cv2.x, cy2: cv2.y, x2: dv.x, y2: dv.y,
      cx3: 0.55, cx4: 1.0, cy4: cy4, x4: 1.0, y4: y4)
    return Path(m)
  }
}
