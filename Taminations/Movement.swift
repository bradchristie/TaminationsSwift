/*

  Taminations Square Dance Animations
  Copyright (C) 2019 Brad Christie

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

  var i:Int { return self.rawValue }

}

class Movement {

  let fullbeats:Double
  let hands:Hands
  let cx1:Double
  let cy1:Double
  let cx2:Double
  let cy2:Double
  let x2:Double
  let y2:Double
  let cx3:Double
  let cx4:Double
  let cy4:Double
  let x4:Double
  let y4:Double
  let beats:Double
  let btranslate:Bezier
  let brotate:Bezier

  //  for sequencer
  var fromCall = true

/**  Constructor for a movement where the dancer does not face the direction
 *   of travel.  Two Bezier curves are used, one for travel and one for
 *   facing direction.
 *
 * @param fullbeats  Timing
 * @param hands  One of the const ints above
 *     Next set of parameters are for direction of travel
 *     X and Y values for start of curve are always 0,0
 * @param cx1    X value for 1st model point
 * @param cy1    Y value for 1st model point
 * @param cx2    X value for 2nd model point
 * @param cy2    Y value for 2nd model point
 * @param x2     X value for end of curve
 * @param y2     Y value for end of curve
 *     Next set of parameters are for facing direction
 *     X and Y values for start of curve, as well as Y value for 1st model
 *     point, are all 0
 * @param cx3    X value for 1st model point
 * @param cx4    X value for 2nd model point
 * @param cy4    Y value for 2nd model point
 * @param x4     X value for end of curve
 * @param y4     Y value for end of curve
 * @param beats  Where to stop for a clipped movement
 */
  init(fullbeats:Double,hands:Hands,
       cx1:Double,cy1:Double,cx2:Double,cy2:Double,x2:Double,y2:Double,
       cx3:Double,cx4:Double,cy4:Double,x4:Double,y4:Double,beats:Double=0) {
    self.fullbeats = fullbeats
    self.hands = hands
    self.cx1 = cx1
    self.cy1 = cy1
    self.cx2 = cx2
    self.cy2 = cy2
    self.x2 = x2
    self.y2 = y2;
    self.cx3 = cx3
    self.cx4 = cx4
    self.cy4 = cy4
    self.x4 = x4
    self.y4 = y4
    self.beats = beats > 0 ? beats : fullbeats
    btranslate = Bezier(x1: 0, y1: 0, ctrlx1: cx1, ctrly1: cy1, ctrlx2: cx2, ctrly2: cy2, x2: x2, y2: y2)
    brotate = Bezier(x1: 0, y1: 0, ctrlx1: cx3, ctrly1: 0, ctrlx2: cx4, ctrly2: cy4, x2: x4, y2: y4)
  }

  /**
   * Construct a Movement from the attributes of an XML movement
   * @param elem from xml
   */
  convenience init(elem:XMLElement) {
    self.init(
      fullbeats: Double(elem.attr("beats")!)!, 
      hands: Hands.getHands(elem.attr("hands") ?? "none"), 
      cx1: Double(elem.attr("cx1")!)!, 
      cy1: Double(elem.attr("cy1")!)!,
      cx2: Double(elem.attr("cx2")!)!,
      cy2: Double(elem.attr("cy2")!)!,
      x2: Double(elem.attr("x2")!)!,
      y2: Double(elem.attr("y2")!)!, 
      cx3: Double(elem.attr("cx3") ?? elem.attr("cx1")!)!,
      cx4: Double(elem.attr("cx4") ?? elem.attr("cx2")!)!,
      cy4: Double(elem.attr("cy4") ?? elem.attr("cy2")!)!, 
      x4: Double(elem.attr("x4") ?? elem.attr("x2")!)!, 
      y4: Double(elem.attr("y4") ?? elem.attr("y2")!)!,
      beats: Double(elem.attr("beats")!)!
    )
  }

  func translate(_ t:Double) -> Matrix {
    let tt = min(max(0,t),fullbeats)
    return btranslate.translate(tt/fullbeats)
  }
  func translate() -> Matrix {
    return translate(beats)
  }

  func rotate(_ t:Double) -> Matrix {
    let tt = min(max(0,t),fullbeats)
    return brotate.rotate(tt/fullbeats)
  }
  func rotate() -> Matrix {
    return rotate(beats)
  }

  /**
   * Return a new movement by changing the beats
   */
  func time(_ b:Double) -> Movement {
    return Movement(fullbeats: b, hands: hands, cx1: cx1, cy1: cy1, cx2: cx2, cy2: cy2, x2: x2, y2: y2,
      cx3: cx3, cx4: cx4, cy4: cy4, x4: x4, y4: y4, beats: b)
  }

  /**
 * Return a new movement by changing the hands
 */
  func useHands(_ h:Hands) -> Movement {
    return Movement(fullbeats: fullbeats, hands: h, cx1: cx1, cy1: cy1, cx2: cx2, cy2: cy2, x2: x2, y2: y2,
      cx3: cx3, cx4: cx4, cy4: cy4, x4: x4, y4: y4, beats: beats)
  }

  /**
   * Return a new Movement scaled by x and y factors.
   * If y is negative hands are also switched.
   */
  func scale(_ x:Double, _ y:Double) -> Movement {
    return Movement(fullbeats: fullbeats,
      hands: y < 0 && hands == .RIGHTHAND ? .LEFTHAND : y < 0 && hands == .LEFTHAND ? .RIGHTHAND : hands  ,
      cx1: cx1*x, cy1: cy1*y, cx2: cx2*x, cy2: cy2*y, x2: x2*x, y2: y2*y, cx3: cx3*x, cx4: cx4*x, cy4: cy4*y, x4: x4*x, y4: y4*y, beats:beats)
  }

  /**
   * Return a new Movement with the end point shifted by x and y
   */
  func skew(_ x:Double, _ y:Double) -> Movement {
    return beats < fullbeats ? skewClip(x,y) : skewFull(x,y)
  }
  func skewFull(_ x:Double, _ y:Double) -> Movement {
    return Movement(fullbeats: fullbeats, hands: hands, cx1: cx1, cy1: cy1, cx2: cx2+x, cy2: cy2+y, x2: x2+x, y2: y2+y,
      cx3: cx3, cx4: cx4, cy4: cy4, x4: x4, y4: y4, beats: beats)
  }
  func skewClip(_ x:Double, _ y:Double) -> Movement {
    var vdelta = Vector(x,y)
    let vfinal = translate().location + vdelta
    var m = self
    var maxiter = 100
    repeat {
      // Shift the end point by the current difference
      m = m.skewFull(vdelta.x, vdelta.y)
      // See how that affects the clip point
      let loc = m.translate().location
      vdelta = vfinal - loc
      maxiter -= 1
    } while (vdelta.length > 0.001 && maxiter > 0)
    //  If timed out, return original rather than something that
    //  might put the dancers in outer space
    return maxiter > 0 ? m : self
  }

  func reflect() -> Movement {
    return scale(1.0, -1.0)
  }

  func clip(_ b:Double) -> Movement {
    return Movement(fullbeats: fullbeats, hands: hands, cx1: cx1, cy1: cy1, cx2: cx2, cy2: cy2, x2: x2, y2: y2,
      cx3: cx3, cx4: cx4, cy4: cy4, x4: x4, y4: y4, beats:b)
  }

  func isStand() -> Bool {
    return x2.isApprox(0.0) && y2.isApprox(0.0) && x4.isApprox(0.0) && y4.isApprox(0.0)
  }

}
