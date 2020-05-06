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

import Foundation

class Vector : CustomStringConvertible {

  let x:Double
  let y:Double

  init(_ x:Double=0.0, _ y:Double=0.0) {
    self.x = x
    self.y = y
  }

  //  So we don't have to type decimal points all the time
  init(_ x:Int, _ y:Int) {
    self.x = x.d
    self.y = y.d
  }

  var description: String {
    "(\(x.s) \(y.s))"
  }

  //  Compute vector length
  var length:Double { get { sqrt(x*x + y*y) } }

  //  Angle off the X-axis
  var angle:Double { get { atan2(y,x) } }

  //  Rotate by a given angle
  func rotate(_ angle2:Double) -> Vector {
    let d = length
    let a = angle + angle2
    return Vector(d * cos(a), d * sin(a))
  }

  //  Multiply by scale factors in one or more dimensions
  func scale(_ sx:Double, _ sy:Double) -> Vector {
    Vector(x*sx, y*sy)
  }

  //  Return difference angle between two vectors
  //  in the range of -pi to pi
  func angleDiff(_ v: Vector) -> Double {
    angleAngleDiff(v.angle, angle)
  }

  //  Return Z-coordinate of the cross product between two vectors
  func crossZ(_ v: Vector) -> Double {
    x * v.y - y * v.x
  }

  func isApprox(_ v2:Vector, delta:Double = 0.1) -> Bool {
    x.isApprox(v2.x,delta: delta) && y.isApprox(v2.y,delta: delta)
  }


}

//  Add another vector
func +(v1:Vector, v2:Vector) -> Vector {
  Vector(v1.x+v2.x, v1.y+v2.y)
}

//  Subtract another vector
func -(v1:Vector, v2:Vector) -> Vector {
  Vector(v1.x-v2.x, v1.y-v2.y)
}

prefix func -(v:Vector) -> Vector {
  Vector(-v.x, -v.y)
}

func *(v:Vector, s:Double) -> Vector {
  v.scale(s,s)
}

extension Vector : Equatable {
  static func ==(left:Vector, right:Vector) -> Bool {
    left.x.isAbout(right.x) && left.y.isAbout(right.y)
  }
}

func angleAngleDiff(_ a1:Double, _ a2:Double) -> Double {
  ((a1-a2 + Double.pi*3).truncatingRemainder(dividingBy: Double.pi*2) ) - Double.pi
}
