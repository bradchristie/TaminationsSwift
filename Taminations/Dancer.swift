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

import UIKit

enum Gender:Int {
  case BOY = 1
  case GIRL = 2
  case PHANTOM = 3
  case NONE = 4    // for concepts with abstract dancers
}

//  info used by sequencer
struct DancerData {
  var active:Bool = true
  var beau:Bool = false
  var belle:Bool = false
  var leader:Bool = false
  var trailer:Bool = false
  var center:Bool = false
  var verycenter:Bool = false
  var end:Bool = false
  var partner: Dancer?
  var actionBeats:Double = 0.0  // needed for moves that analyze previous action, like Roll
}

//  Dancer Space is a coordinate system where the dancer
//  is at (0,0) and looking down the X axis.
//  Convert a point from world space to dancer space
//  based on the dancer's current location.
extension Vector {
  func ds(_ d:Dancer) -> Vector { d.tx.inverse() * self }
}

//  Take a list of dancers in any order, re-order
//  in pairs of diagonal opposites
extension Array where Element:Dancer {
  func inOrder() -> [Dancer] {
    self.filter { $0.location.x.isGreaterThan(0.0) ||
      ($0.location.x.isAbout(0.0) && $0.location.y.isGreaterThan(0.0)) }
    .flatMap { d in [d,self.first { $0.location == -d.location }!] }
  }
}

class Dancer : Comparable, CustomStringConvertible {

  static let NUMBERS_OFF = 0
  static let NUMBERS_DANCERS = 1
  static let NUMBERS_COUPLES = 2
  static let NUMBERS_NAMES = 3  // sequencer only

  let number:String
  let number_couple:String
  let gender:Gender
  var fillcolor:UIColor
  var starttx:Matrix
  let geom:Geometry
  let moves:[Movement]
  let clonedFrom:Dancer?
  var drawColor:UIColor { get { fillcolor.darker() } }
  var showNumber = Dancer.NUMBERS_OFF
  var showColor = true
  var showShape = true
  var hidden = false
  var path:Path
  var showPath = false
  var hands = Hands.NOHANDS
  var tx = Matrix()
  private var pathpath = DrawingPath()
  var beats:Double { get { path.beats } }
  //  Other vars for computing handholds
  var leftdancer: Dancer? = nil
  var rightdancer: Dancer? = nil
  var rightgrip: Dancer? = nil
  var leftgrip: Dancer? = nil
  var rightHandVisibility = false
  var leftHandVisibility = false
  var rightHandNewVisibility = false
  var leftHandNewVisibility = false
  var data:DancerData
  var name=""  // for sequencer

  init(number:String, couple:String, gender:Int,
       fillcolor:UIColor, mat:Matrix, geom:Geometry, moves:[Movement], clonedFrom:Dancer?=nil) {
    self.number = number
    self.number_couple = couple
    self.gender = Gender(rawValue: gender)!
    self.fillcolor = fillcolor
    self.geom = geom
    self.moves = moves
    self.clonedFrom = clonedFrom
    self.path = Path(moves)
    data = DancerData()
    starttx = geom.startMatrix(mat)
    // Compute points of path for drawing path
    animateComputed(beat: -2.0)
    var loc = location
    pathpath.moveTo(loc.x,loc.y)
    for beat10 in 0...(beats*10.0).i {
      animateComputed(beat: beat10.d/10.0)
      loc = location
      pathpath.lineTo(loc.x,loc.y)
    }
    //  Restore dancer to start position
    animateComputed(beat:-2.0)
  }

  convenience init(_ from:Dancer, number:String="", number_couple:String="", gender:Int=0) {
    self.init(number: number == "" ? from.number : number,
              couple: number_couple == "" ? from.number_couple : number_couple,
              gender: gender == 0 ? from.gender.rawValue : gender,
      fillcolor: from.fillcolor, mat: from.tx,
      //  Already geometrically rotated so don't do it again
      geom: GeometryMaker.makeOne(from.geom.geometry(),r:0), moves: [], clonedFrom: from)
    data.active = from.data.active
  }

  //  Required methods for Comparable
  static func < (lhs:Dancer, rhs:Dancer) -> Bool {
    lhs.number < rhs.number
  }
  static func == (lhs:Dancer, rhs:Dancer) -> Bool {
    lhs.number == rhs.number
  }
  //  Property for CustomStringConvertible
  var description: String { number }

  var isPhantom:Bool { gender == .PHANTOM }

  var location:Vector { tx.location }

  //  distance to another dancer
  func distanceTo(_ d2:Dancer) -> Double {
    (location - d2.location).length
  }

  //  angle the dancer is facing relative to the positive x-axis
  var angleFacing:Double { tx.angle }

  //  angle of the dancer's position relative to the positive x-axis
  var anglePosition:Double { tx.location.angle }

  //  angle the dancer turns to look at the origin
  var angleToOrigin:Double { (tx.inverse() * Vector(0,0)).angle }

  func vectorToDancer(_ d2:Dancer) -> Vector {
    tx.inverse() * d2.location
  }
  //  Angle of d2 as viewed from this dancer
  //  If angle is 0 then d2 is in front
  //  Angle returned is in the range -pi to pi
  func angleToDancer(_ d2:Dancer) -> Double {
    vectorToDancer(d2).angle
  }

  //  Other geometric interrogatives
  var isFacingIn:Bool {
    let a = angleToOrigin.abs
    return !a.isApprox(.pi/2) && a < .pi/2
  }

  var isFacingOut:Bool {
    let a = angleToOrigin.abs
    return !a.isApprox(.pi/2) && a > .pi/2
  }

  var isCenterLeft:Bool {
    angleToOrigin > 0
  }

  var isCenterRight:Bool {
    angleToOrigin < 0
  }

  var isOnXAxis:Bool {
    location.y.isAbout(0.0)
  }

  var isOnYAxis:Bool {
    location.x.isAbout(0.0)
  }

  var isOnAxis: Bool {
    isOnXAxis || isOnYAxis
  }

  var isTidal:Bool {
    (isOnXAxis || isOnYAxis) && (isCenterLeft || isCenterRight)
  }

  func isInFrontOf(_ d2:Dancer) -> Bool {
    self != d2 && d2.angleToDancer(self).angleEquals(0.0)
  }

  func isInBackOf(_ d2:Dancer) -> Bool {
    self != d2 && d2.angleToDancer(self).angleEquals(.pi)
  }

  func isRightOf(_ d2:Dancer) -> Bool {
    self != d2 && d2.angleToDancer(self).angleEquals(.pi*3/2)
  }

  func isLeftOf(_ d2:Dancer) -> Bool {
    self != d2 && d2.angleToDancer(self).angleEquals(.pi/2)
  }

  func isOpposite(_ d2:Dancer) -> Bool {
    self != d2 && (location + d2.location).length.isApprox(0.0)
  }


  /**
   *   Used for hexagon handholds
   * @return  True if dancer is close enough to center to make a center star
   */
  var inCenter:Bool { location.length < 1.1 }

  /**
   *   Move dancer to location along path
   * @param beat where to place dancer
   */
  private func animateComputed(beat:Double) {
    hands = path.hands(beat)
    tx = starttx * path.animate(beat)
    tx = geom.pathMatrix(starttx,tx:tx,beat:beat) * tx
  }

  func animateToEnd() { animate(beat:beats) }

  func animate(beat:Double) { animateComputed(beat:beat) }

  @discardableResult
  func setStartPosition(_ pos:Vector) -> Dancer {
    let a = angleFacing
    starttx = Matrix(x:pos.x,y:pos.y) * Matrix(angle:a)
    tx = Matrix(starttx)
    return self
  }

  @discardableResult
  func rotateStartAngle(_ angle:Double) -> Dancer {
    starttx = starttx * Matrix(angle:angle.toRadians)
    tx = Matrix(starttx)
    return self
  }

  /**
   *   Draw the entire dancer's path as a translucent colored line
   * @param c  Canvas to draw to
   */
  func drawPath(_ c: DrawingContext) {
    //  The path color is a partly transparent version of the draw color
    c.drawPath(pathpath,DrawingStyle(color:drawColor,alpha:0.5,lineWidth: 0.1))
  }

  //  Draw the dancer at its current position
  func draw(_ c:DrawingContext) {
    let dc = showColor ? drawColor : UIColor.gray
    let fc = showColor ? fillcolor : UIColor.lightGray
    //  Draw the head
    let p = DrawingStyle(color:dc)
    c.fillCircle(x:0.5,y:0.0,radius:0.33,p:p)
    //  Draw the body
    p.color = (showNumber == Dancer.NUMBERS_OFF || gender == .PHANTOM)
      ? fc : fc.veryBright()
    let rect = CGRect(x: -0.5, y: -0.5, width: 1.0, height: 1.0)
    if (!showShape || gender == .PHANTOM) {
      c.fillRoundRect(rect: rect, rad: 0.3, p: p)
    } else if (gender == .BOY) {
      c.fillRect(rect: rect, p: p)
    } else if (gender == .GIRL) {
      c.fillCircle(x: 0.0, y: 0.0, radius: 0.5, p: p)
    }
    //  Draw the body outline
    p.lineWidth = 0.1
    p.color = dc
    if (!showShape || gender == .PHANTOM) {
      c.drawRoundRect(rect: rect, rad: 0.3, p: p)
    } else if (gender == .BOY) {
      c.drawRect(rect: rect, p: p)
    } else if (gender == .GIRL) {
      c.drawCircle(x: 0.0, y: 0.0, radius: 0.5, p: p)
    }
    //  Draw number if  on
    if (showNumber != Dancer.NUMBERS_OFF) {
      //  The dancer is rotated relative to the display, but of course
      //  the dancer number should not be rotated.
      //  So the number needs to be transformed back
      let txtext = Matrix(angle: -atan2(tx.m12,tx.m22) + .pi / 2)
      c.transform(txtext)
      c.scale(-0.1, 0.1)

      var t = number
      if (showNumber == Dancer.NUMBERS_COUPLES) {
        t = number_couple
      } else if (showNumber == Dancer.NUMBERS_NAMES) {
        t = name
      }
      c.fillText(t,x:0,y:0,DrawingStyle(textSize: 7.0, textAlign: .CENTER))
    }

  }

}
