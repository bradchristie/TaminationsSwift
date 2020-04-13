//
// Created by Bradley Christie on 2019-02-15.
// Copyright (c) 2019 bradchristie. All rights reserved.
//

import Foundation

class Vector {

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

  //  Compute vector length
  var length:Double { get { return sqrt(x*x + y*y) } }

  //  Angle off the X-axis
  var angle:Double { get { return atan2(y,x) } }

  //  Rotate by a given angle
  func rotate(_ angle2:Double) -> Vector {
    let d = length
    let a = angle + angle2
    return Vector(d * cos(a), d * sin(a))
  }

  //  Multiply by scale factors in one or more dimensions
  func scale(_ sx:Double, _ sy:Double) -> Vector {
    return Vector(x*sx, y*sy)
  }

  //  Return difference angle between two vectors
  //  in the range of -pi to pi
  func angleDiff(_ v: Vector) -> Double {
    return angleAngleDiff(v.angle, angle)
  }

  //  Return Z-coord of the cross product between two vectors
  func crossZ(_ v: Vector) -> Double {
    return x * v.y - y * v.x
  }

  func isApprox(_ v2:Vector, delta:Double = 0.1) -> Bool {
    x.isApprox(v2.x,delta: delta) && y.isApprox(v2.y,delta: delta)
  }


}

//  Add another vector
func +(v1:Vector, v2:Vector) -> Vector {
  return Vector(v1.x+v2.x, v1.y+v2.y)
}

//  Subtract another vector
func -(v1:Vector, v2:Vector) -> Vector {
  return Vector(v1.x-v2.x, v1.y-v2.y)
}

prefix func -(v:Vector) -> Vector {
  return Vector(-v.x, -v.y)
}

func *(v:Vector, s:Double) -> Vector {
  return v.scale(s,s)
}

func angleAngleDiff(_ a1:Double, _ a2:Double) -> Double {
  return ((a1-a2 + Double.pi*3).truncatingRemainder(dividingBy: Double.pi*2) ) - Double.pi
}
