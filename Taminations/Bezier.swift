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

class Bezier {

  private let x1:Double
  private let y1:Double
  private let ctrlx1:Double
  private let ctrly1:Double
  private let ctrlx2:Double
  private let ctrly2:Double
  private let x2:Double
  private let y2:Double
  private let ax:Double
  private let ay:Double
  private let bx:Double
  private let by:Double
  private let cx:Double
  private let cy:Double

  //  Constructor from 4 points along the curve
  //  at times 0, 1/3, 2/3, 1
  //  Reference:  https://web.archive.org/web/20131225210855/http://people.sc.fsu.edu/~jburkardt/html/bezier_interpolation.html
  static func fromPoints(_ p0:Vector, _ p1:Vector, _ p2:Vector, _ p3:Vector) -> Bezier {
    let pc1 = Vector(
      (-5.0*p0.x + 18.0*p1.x - 9.0*p2.x + 2.0*p3.x)/6.0,
      (-5.0*p0.y + 18.0*p1.y - 9.0*p2.y + 2.0*p3.y)/6.0
    )
    let pc2 = Vector(
      (2.0*p0.x - 9.0*p1.x + 18.0*p2.x - 5.0*p3.x)/6.0,
      (2.0*p0.y - 9.0*p1.y + 18.0*p2.y - 5.0*p3.y)/6.0
    )
    return Bezier(x1:p0.x, y1:p0.y, ctrlx1:pc1.x, ctrly1:pc1.y,
                  ctrlx2:pc2.x, ctrly2:pc2.y, x2:p3.x, y2:p3.y)
  }

  init(x1:Double,y1:Double,ctrlx1:Double,ctrly1:Double,ctrlx2:Double,ctrly2:Double,x2:Double,y2:Double) {
    self.x1 = x1
    self.y1 = y1
    self.ctrlx1 = ctrlx1
    self.ctrly1 = ctrly1
    self.ctrlx2 = ctrlx2
    self.ctrly2 = ctrly2
    self.x2 = x2
    self.y2 = y2

    cx = 3.0*(ctrlx1-x1)
    bx = 3.0*(ctrlx2-ctrlx1) - cx
    ax = x2 - x1 - cx - bx

    cy = 3.0*(ctrly1-y1)
    by = 3.0*(ctrly2-ctrly1) - cy
    ay = y2 - y1 - cy - by
  }

  var endPoint:Vector { Vector(x2,y2) }

  //  Compute X, Y values for a specific t value
  func xt(_ t:Double) -> Double {
    x1 + t*(cx + t*(bx + t*ax))
  }
  func yt(_ t:Double) -> Double {
    y1 + t*(cy + t*(by + t*ay))
  }
  func pt(_ t:Double) -> Vector {
    Vector(xt(t),yt(t))
  }

  //  Compute dx, dy values for a specific t value
  private func dxt(_ t:Double) -> Double {
    cx + t*(2.0*bx + t*3.0*ax)
  }
  private func dyt(_ t:Double) -> Double {
    cy + t*(2.0*by + t*3.0*ay)
  }
  private func angle(_ t:Double) -> Double {
    atan2(dyt(t),dxt(t))
  }

  //  Return the movement along the curve given "t" between 0 and 1
  func translate(_ t:Double) -> Matrix {
    let x = xt(t)
    let y = yt(t)
    return Matrix(x:x,y:y)
  }

  func rotate(_ t:Double) -> Matrix {
    let theta = angle(t)
    return Matrix(angle:theta)
  }

  //  Return turn direction at end of curve
  func rolling()->Double {
    //  Check angle at end
    var theta = angle(1.0)
    //  If it's 180 then use angle at halfway point
    if (theta.angleEquals(.pi)) {
      theta = angle(0.5)
    }
    //  If angle is 0 then no turn
    return (theta.angleEquals(0.0)) ? 0.0 : theta
  }

  //  Well, there could be control points way out but this is ok for our use
  func isIdentity() -> Bool {
    x2.isAbout(0.0) && y2.isAbout(0.0)
  }

  ////  Functions to compute a new Bezier
  func scale(_ x:Double, _ y:Double) -> Bezier {
    Bezier(x1:x1*x, y1:y1*y, ctrlx1:ctrlx1*x, ctrly1:ctrly1*y,
           ctrlx2:ctrlx2*x, ctrly2:ctrly2*y, x2:x2*x, y2:y2*y)
  }

  func skew(_ x:Double, _ y:Double) -> Bezier {
    Bezier(x1:x1, y1:y1, ctrlx1:ctrlx1, ctrly1:ctrly1,
           ctrlx2:ctrlx2+x, ctrly2:ctrly2+y, x2:x2+x, y2:y2+y)
  }

  func clip(_ fraction:Double) -> Bezier {
    let p1 = pt(0.0)
    let p2 = pt(fraction / 3.0)
    let p3 = pt(fraction * 2.0 / 3.0)
    let p4 = pt(fraction)
    return Bezier.fromPoints(p1,p2,p3,p4)
  }

}
