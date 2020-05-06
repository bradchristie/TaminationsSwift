//
// Created by Bradley Christie on 2019-02-15.
// Copyright (c) 2019 bradchristie. All rights reserved.
//

import Foundation

/*
Table for matrix fields iOS and Java
iOS                         Java                                     Win Matrix3x2
a   c   tx        MSCALE_X(0)    MSKEW_X(1)    MTRANS_X(2)       M11    M21   M31
b   d   ty        MSKEW_Y(3)     MSCALE_Y(4)   MTRANS_Y(5)       M12    M22   M32
0   0   1         MPERSP_0(6)    MPERSP_1(7)   MPERSP_2(8)       0      0     1

*/

class Matrix {

  let m11,m21,m31,m12,m22,m32:Double

  init(_ m11:Double, _ m21:Double, _ m31:Double,
       _ m12:Double, _ m22:Double, _ m32:Double) {
    self.m11 = m11
    self.m21 = m21
    self.m31 = m31
    self.m12 = m12
    self.m22 = m22
    self.m32 = m32
  }

  //  Identity matrix
  convenience init() {
    self.init(1,0,0,0,1,0)
  }

  //  Copy constructor
  convenience init(_ m:Matrix) {
    self.init(m.m11,m.m21,m.m31,m.m12,m.m22,m.m32)
  }

  //  Create rotation matrix
  convenience init(angle:Double) {
    self.init(cos(angle),-sin(angle),0.0,sin(angle),cos(angle),0.0)
  }

  //  Create translation matrix
  convenience init(x:Double,y:Double) {
    self.init(1.0,0.0,x,0.0,1.0,y)
  }

  //  Compute and return this * m
  fileprivate func multiply(_ m: Matrix) -> Matrix {
    Matrix(
      m11 * m.m11 + m21 * m.m12,
      m11 * m.m21 + m21 * m.m22,
      m11 * m.m31 + m21 * m.m32 + m31,
      m12 * m.m11 + m22 * m.m12,
      m12 * m.m21 + m22 * m.m22,
      m12 * m.m31 + m22 * m.m32 + m32)
  }

  //  Compute and return this * v
  fileprivate func multiply(_ v: Vector) -> Vector {
    Vector(
      m11 * v.x + m21 * v.y + m31,
      m12 * v.x + m22 * v.y + m32)
  }

  //  This is for rotation transforms only,
  //  or when using as a 2x2 matrix (as in SVD)
  func transpose() -> Matrix {
    Matrix(m11, m12, 0.0, m21, m22, 0.0)
  }

  var location:Vector { get { Vector(m31,m32) } }
  var direction:Vector { get { Vector(m11,m21) } }
  var angle:Double { get { atan2(m12,m22) } }

  //  Compute and return the inverse matrix - only for affine transform matrix
  func inverse() -> Matrix {
    let det = m11 * m22 - m21 * m12
    return Matrix(
      m22 / det,
      -m21 / det,
      (m21 * m32 - m22 * m31) / det,
      -m12 / det,
      m11 / det,
      (m12 * m31 - m11 * m32) / det)
  }

  //  If a rotation matrix is close to a 90 degree angle,snap to it
  func snapTo90(delta:Double=0.1) -> Matrix {
    Matrix(snapDouble(m11,delta:delta),snapDouble(m21,delta:delta),m31,
           snapDouble(m12,delta:delta),snapDouble(m22,delta:delta),m32)
  }

  //  SVD simple and fast for 2x2 arrays
  //  for matching 2d formations
  func svd22() -> (Matrix,[Double], Matrix) {
    let a = m11
    let b = m12
    let c = m21
    let d = m22
    //  Check for trivial case
    let epsilon = 0.0001
    if (b.abs < epsilon && c.abs < epsilon) {
      let v = Matrix((a < 0.0) ? -1.0 : 1.0, 0, 0,
        0, (d < 0.0) ? -1.0 : 1.0, 0)
      let sigma = [a.abs, d.abs]
      let u = Matrix()
      return (u, sigma, v)
    } else {
      let atanarg1 = 2 * a * c + 2 * b * d
      let atanarg2 = a * a + b * b - c * c - d * d
      let theta = 0.5 * atan2(atanarg1, atanarg2)
      let u = Matrix(theta.Cos, -theta.Sin, 0.0,
        theta.Sin, theta.Cos, 0.0)

      let phi = 0.5 * atan2(2 * a * b + 2 * c * d, a.sq - b.sq + c.sq - d.sq)
      let s11 = (a * theta.Cos + c * theta.Sin) * phi.Cos +
        (b * theta.Cos + d * theta.Sin) * phi.Sin
      let s22 = (a * theta.Sin - c * theta.Cos) * phi.Sin +
        (-b * theta.Sin + d * theta.Cos) * phi.Cos

      let s1 = a.sq + b.sq + c.sq + d.sq
      let s2 = ((a.sq + b.sq - c.sq - d.sq).sq + 4 * (a * c + b * d).sq).Sqrt
      let sigma = [(s1 + s2).Sqrt / 2, (s1 - s2).Sqrt / 2]

      let v = Matrix(s11.sign * phi.Cos, -s22.sign * phi.Sin, 0.0,
        s11.sign * phi.Sin, s22.sign * phi.Cos, 0.0)
      return (u, sigma, v)
    }
  }

}

func *(m1:Matrix, m2:Matrix) -> Matrix {
  m1.multiply(m2)
}
func *(m:Matrix, v:Vector) -> Vector {
  m.multiply(v)
}

private func snapDouble(_ x:Double, delta:Double) -> Double {
  if (x.isApprox(0.0, delta:delta)) {
    return 0.0
  }
  if (x.isApprox(1.0, delta:delta)) {
    return 1.0
  }
  if (x.isApprox(-1.0, delta:delta)) {
    return -1.0
  }
  return x
}
