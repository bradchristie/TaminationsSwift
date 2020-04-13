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

class CounterRotate : Action {

  override var level: LevelData { LevelObject.find("c1") }

  init() {
    super.init("Counter Rotate")
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    let da = d.angleToOrigin
    //  Counter Rotate not possible if dancer is looking
    //  directly at the center of the square
    if (da.isAround(0.0)) {
      throw CallError("Dancer $d cannot Counter Rotate")
    }
    //  Compute points for Bezier
    let anginc = .pi/6.0 * da.sign
    let p1 = d.location.ds(d)
    let p2 = d.location.rotate(anginc).ds(d)
    let p3 = d.location.rotate(anginc*2.0).ds(d)
    let p4 = d.location.rotate(anginc*3.0).ds(d)
    let bz = Bezier.fromPoints(p1,p2,p3,p4)
    //  Get turn, which is 1/4 right or left
    let turn = (da < 0) ? "Right" : "Left"
    let brot = TamUtils.getMove("Quarter \(turn)").movelist[0].brotate
    let beats = ceil(d.location.length)
    let move = Movement(beats: beats,hands: Hands.NOHANDS,btranslate: bz,brotate: brot)
    return Path(move)

  }

}
