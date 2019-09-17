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


import UIKit

extension DrawingContext {

  func gridPaint() -> DrawingStyle {
    return DrawingStyle(color: UIColor.lightGray,
      lineWidth: 0.01)
      // lineWidth: 1.0/min(height,width).d/13.0)
  }

}

enum GeometryType:Int {
  case BIGON = 1
  case SQUARE = 2
  case HEXAGON = 3
}

protocol Geometry {

  func startMatrix(_ mat:Matrix) -> Matrix;
  func pathMatrix(_ starttx:Matrix, tx:Matrix, beat:Double) -> Matrix;
  func drawGrid(_ ctx:DrawingContext)
  func geometry() -> GeometryType
  func clone() -> Geometry

}

extension Geometry {
  var BIGON:Int { return 1 }
  var SQUARE:Int { return 2 }
  var HEXAGON:Int { return 3 }
}


class GeometryMaker {

  static func makeAll(_ type:GeometryType) -> [Geometry] {
    switch type {
    case .BIGON : return [BigonGeometry(0)]
    case .SQUARE : return [SquareGeometry(0),SquareGeometry(1)]
    case .HEXAGON : return [HexagonGeometry(0),HexagonGeometry(1),HexagonGeometry(2)]
    }
  }

  static func makeOne(_ g:GeometryType, r:Int=0) -> Geometry {
    switch g {
    case .BIGON : return BigonGeometry(r)
    case .SQUARE : return SquareGeometry(r)
    case .HEXAGON : return HexagonGeometry(r)
    }
  }

  static func makeOne(_ gstr:String, r:Int=0) -> Geometry {
    switch gstr {
    case "Bi-gon" : return BigonGeometry(r)
    case "Hexagon" : return HexagonGeometry(r)
    default : return SquareGeometry(r)
    }
  }



}
///////////////////////////////////////////////////////////////////////////
class BigonGeometry : Geometry {
  let rotnum:Int
  var prevangle = 0.0
  init(_ rotnum:Int) { self.rotnum = rotnum }
  func geometry() -> GeometryType { return .BIGON }
  func clone() -> Geometry { return BigonGeometry(rotnum) }

  func startMatrix(_ mat: Matrix) -> Matrix {
    let x = mat.m31
    let y = mat.m32
    let r = sqrt(x*x+y*y)
    let startangle = atan2(mat.m12,mat.m22)
    let angle = atan2(y,x) + .pi
    let bigangle = angle*2 - .pi
    let x2 = r*cos(bigangle)
    let y2 = r*sin(bigangle)
    let startangle2 = startangle + angle
    return Matrix(x:x2,y:y2) * Matrix(angle:startangle2)
  }

  func pathMatrix(_ starttx: Matrix, tx: Matrix, beat: Double) -> Matrix {
    let x = starttx.m31
    let y = starttx.m32
    let a0 = atan2(y, x)
    let x2 = tx.m31
    let y2 = tx.m32
    let a1 = atan2(y2, x2)
    if (beat <= 0) {
      prevangle = a1
    }
    let wrap = round((a1-prevangle)/(.pi*2))
    let a2 = a1 - wrap * .pi * 2.0
    let a3 = a2 - a0
    prevangle = a2
    return Matrix(angle:a3)
  }

  func drawGrid(_ ctx: DrawingContext) {
    let p = ctx.gridPaint()
    for xscale:Double in [-1,1] {
      ctx.save()
      ctx.scale(xscale, 1.0)
      for x1 in stride(from: -7.5, through:7.5, by:1.0) {
        let path = DrawingPath()
        path.moveTo(x1.abs, 0.0)
        for y1 in stride(from: 0.2, through:7.5, by:0.2) {
          let a = 2.0 * atan2(y1,x1)
          let r = sqrt(x1*x1+y1*y1)
          let x = r*cos(a)
          let y = r*sin(a)
          path.lineTo(x,y)
        }
        ctx.drawPath(path,p)
      }
      ctx.restore()
    }
  }

}
///////////////////////////////////////////////////////////////////////////
class SquareGeometry : Geometry {
  let rotnum:Int
  init(_ rotnum:Int) { self.rotnum = rotnum }
  func geometry() -> GeometryType { return .SQUARE }
  func clone() -> Geometry { return SquareGeometry(rotnum) }

  func startMatrix(_ mat:Matrix) -> Matrix {
    return Matrix(angle: .pi * rotnum.d) * mat
  }

  func pathMatrix(_ starttx: Matrix, tx: Matrix, beat: Double) -> Matrix {
    //  No transform needed
    return Matrix()
  }

  func drawGrid(_ ctx: DrawingContext) {
    let p = ctx.gridPaint()
    for x in stride(from: -7.5, through: 7.5, by: 1.0) {
      ctx.drawLine(x1: x, y1: -7.5, x2: x, y2: 7.5, p)
    }
    for y in stride(from: -7.5, through:7.5, by:1.0) {
      ctx.drawLine(x1: -7.5, y1: y, x2: 7.5, y2: y, p)
    }
  }

}
///////////////////////////////////////////////////////////////////////////
class HexagonGeometry : Geometry {
  let rotnum:Int
  var prevangle = 0.0
  init(_ rotnum:Int) { self.rotnum = rotnum }
  func geometry() -> GeometryType { return .HEXAGON }
  func clone() -> Geometry { return HexagonGeometry(rotnum) }

  func startMatrix(_ mat: Matrix) -> Matrix {
    let a = (.pi * 2.0/3.0) * rotnum.d
    let x = mat.m31
    let y = mat.m32
    let r = sqrt(x*x+y*y)
    let startangle = atan2(mat.m12, mat.m22)
    let angle = atan2(y,x)
    let dangle = angle < 0 ? -(.pi+angle)/3 : (.pi-angle)/3
    let x2 = r * cos(angle+dangle+a)
    let y2 = r * sin(angle+dangle+a)
    let startangle2 = startangle + a + dangle
    return Matrix(x:x2,y:y2) * Matrix(angle:startangle2)
  }

  func pathMatrix(_ starttx: Matrix, tx: Matrix, beat: Double) -> Matrix {
    //  Get dancer's start angle and current angle
    let x = starttx.m31
    let y = starttx.m32
    let a0 = atan2(y,x)
    let x2 = tx.m31
    let y2 = tx.m32
    let a1 = atan2(y2,x2)
    //  Correct for wrapping around +/- pi
    if (beat <= 0) {
      prevangle = a1
    }
    let wrap = round((a1-prevangle)/(.pi * 2.0))
    let a2 = a1 - wrap * .pi * 2.0
    let a3 = -(a2-a0)/3.0
    prevangle = a2
    return Matrix(angle:a3)
  }

  func drawGrid(_ ctx: DrawingContext) {
    let p = ctx.gridPaint()
    for yscale in stride(from: -1.0, through: 1.0, by:2.0) {
      for a in stride(from: 0.0, through:6.0, by:1.0) {
        ctx.save()
        ctx.rotate(.pi/6.0 + a * .pi/3.0)
        ctx.scale(1.0,yscale)
        for x0 in stride(from: 0.0, through:8.5, by:1.0) {
          let path = DrawingPath()
          path.moveTo(0.0, x0)
          for y0 in stride(from: 0.5, through: 8.5, by: 0.5) {
            let aa = atan2(y0,x0) * 2.0 / 3.0
            let r = sqrt(x0*x0 + y0*y0)
            let x = r * sin(aa)
            let y = r * cos(aa)
            path.lineTo(x,y)
          }
          ctx.drawPath(path, p)
        }
        ctx.restore()
      }
    }
  }

}

