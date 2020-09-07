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

enum Hands : Int {
  case NOHANDS = 0
  case LEFTHAND = 1
  case RIGHTHAND = 2
  case BOTHHANDS = 3
  case ANYGRIP = 4
  case GRIPLEFT = 5
  case GRIPRIGHT = 6
  case GRIPBOTH = 7

  static func getHands(_ h:String) -> Hands {
    switch (h) {
    case "none" : return NOHANDS
    case "nohands" : return NOHANDS
    case "left" : return LEFTHAND
    case "right" : return RIGHTHAND
    case "both" : return BOTHHANDS
    case "anygrip" : return ANYGRIP
    case "gripleft" : return GRIPLEFT
    case "gripright" : return GRIPRIGHT
    case "gripboth" : return GRIPBOTH
    default : fatalError()
    }
  }

  var i:Int { self.rawValue }

}

class Movement {

  let hands:Hands
  let beats:Double
  let btranslate:Bezier
  let brotate:Bezier

  //  for sequencer
  let fromCall:Bool

/**  Constructor for a movement where the dancer does not face the direction
 *   of travel.  Two Bezier curves are used, one for travel and one for
 *   facing direction.
 *
 * @param beats  Timing
 * @param hands  One of the const ints above
 * @param btranslate  Bezier curve for movement
 * @param brotate  Bezier curve for facing direction, can be same as btranslate
 */
  init(beats:Double,hands:Hands,
       btranslate:Bezier,
       brotate:Bezier,
       fromCall:Bool=true) {
    self.hands = hands
    self.beats = beats
    self.btranslate = btranslate
    self.brotate = brotate
    self.fromCall = fromCall
  }

  /**
   * Construct a Movement from the attributes of an XML movement
   * @param elem from xml
   */
  convenience init(elem:XMLElement) {
    self.init(
      beats: Double(elem.attr("beats")!)!,
      hands: Hands.getHands(elem.attr("hands") ?? "none"),
      btranslate: Bezier(x1:0.0, y1:0.0,
          ctrlx1: Double(elem.attr("cx1")!)!,
          ctrly1: Double(elem.attr("cy1")!)!,
          ctrlx2: Double(elem.attr("cx2")!)!,
          ctrly2: Double(elem.attr("cy2")!)!,
          x2: Double(elem.attr("x2")!)!,
          y2: Double(elem.attr("y2")!)!),
      brotate: Bezier(x1:0.0, y1:0.0,
          ctrlx1: Double(elem.attr("cx3") ?? elem.attr("cx1")!)!,
          ctrly1:0.0,
          ctrlx2: Double(elem.attr("cx4") ?? elem.attr("cx2")!)!,
          ctrly2: Double(elem.attr("cy4") ?? elem.attr("cy2")!)!,
          x2: Double(elem.attr("x4") ?? elem.attr("x2")!)!,
          y2: Double(elem.attr("y4") ?? elem.attr("y2")!)!)
    )
  }

  func translate(_ t:Double) -> Matrix {
    let tt = min(max(0,t),beats)
    return btranslate.translate(tt/beats)
  }
  func translate() -> Matrix {
    translate(beats)
  }

  func rotate(_ t:Double) -> Matrix {
    let tt = min(max(0,t),beats)
    return brotate.rotate(tt/beats)
  }
  func rotate() -> Matrix {
    rotate(beats)
  }

  /**
   * Return a new movement by changing the beats
   */
  func time(_ b:Double) -> Movement {
    Movement(beats: b, hands: hands, btranslate: btranslate, brotate: brotate, fromCall: fromCall)
  }

  /**
 * Return a new movement by changing the hands
 */
  func useHands(_ h:Hands) -> Movement {
    Movement(beats: beats, hands: h, btranslate: btranslate, brotate: brotate, fromCall: fromCall)
  }

  func notFromCall() -> Movement {
    Movement(beats: beats, hands: hands, btranslate: btranslate, brotate: brotate, fromCall: false)
  }

  /**
   * Return a new Movement scaled by x and y factors.
   * If y is negative hands are also switched.
   */
  func scale(_ x:Double, _ y:Double) -> Movement {
    Movement(beats: beats,
      hands: y < 0 && hands == .RIGHTHAND ? .LEFTHAND
           : y < 0 && hands == .LEFTHAND ? .RIGHTHAND
           : y < 0 && hands == .GRIPRIGHT ? .GRIPLEFT
           : y < 0 && hands == .GRIPLEFT ? .GRIPRIGHT
           : hands  ,
      btranslate: btranslate.scale(x,y),
      brotate: brotate.scale(x,y))
  }

  /**
   * Return a new Movement with the end point shifted by x and y
   */
  func skew(_ x:Double, _ y:Double) -> Movement {
    Movement(beats: beats, hands: hands,
      btranslate: btranslate.skew(x,y),
      brotate: brotate)
  }

  /**
   * Skew a movement based on an  adjustment to the final position
   */
  func skewFromEnd(_ x:Double, _ y:Double) -> Movement {
    let a = rotate().angle
    let v = Vector(x,y).rotate(a)
    return skew(v.x,v.y)
  }

  func reflect() -> Movement {
    scale(1.0, -1.0)
  }

  func clip(_ b:Double) -> Movement {
    let fraction = b / beats
    return Movement(beats: b, hands: hands, btranslate: btranslate.clip(fraction), brotate: brotate.clip(fraction))
  }

  func isStand() -> Bool {
    btranslate.isIdentity() && brotate.isIdentity()
  }

}
