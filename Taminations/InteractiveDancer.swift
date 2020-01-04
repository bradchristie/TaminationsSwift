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

class InteractiveDancer : Dancer {

  static let ANGLESENSITIVITY = 0.5
  static let MOVESENSITIVITY = 1.0
  static let DIRECTIONALPHA = 0.9
  static let DIRECTIONTHRESHOLD = 0.002
  static let NOPOINT = Vector()
  static let NODIRECTION = Vector()

  var onTrack = true

  //  For moving dancer with fingers
  private var primaryid:UITouch? = nil
  private var secondaryid:UITouch? = nil
  private var primaryTouch = NOPOINT
  private var primaryMove = NOPOINT
  private var secondaryTouch = NOPOINT
  private var secondaryMove = NOPOINT
  private let primaryIsLeft = Setting("PrimaryControl").s == "Left"
  private var primaryDirection = NODIRECTION

  //  Need a val for original fill color, as we change it
  private var onTrackColor: UIColor {
    return fillcolor
  }
  override var drawColor: UIColor {
    return onTrackColor.darker()
  }

  //  Return where dancer should be
  func computeMatrix(_ beat: Double) -> Matrix {
    let savetx = Matrix(tx)
    super.animate(beat: beat)
    let computetx = Matrix(tx)
    tx = savetx
    return computetx
  }

  override func animate(beat: Double) {
    fillcolor = (beat <= 0.0 || onTrack)
      ? onTrackColor.veryBright()
      : UIColor.gray
    if (beat <= -1.0) {
      tx = Matrix(starttx)
      primaryTouch = Vector()
      primaryMove = Vector()
    } else {

      if (primaryMove !== InteractiveDancer.NOPOINT) {
        let d = (primaryMove - primaryTouch) * InteractiveDancer.MOVESENSITIVITY
        tx = Matrix(x: d.x, y: d.y) * tx
        if (secondaryMove === InteractiveDancer.NOPOINT) {
          //  Rotation follow movement
          if (primaryDirection === InteractiveDancer.NODIRECTION) {
            primaryDirection = d
          } else {
            let dd = Vector(
              //  this smooths the rotation
              InteractiveDancer.DIRECTIONALPHA * primaryDirection.x + (1 - InteractiveDancer.DIRECTIONALPHA) * d.x,
              InteractiveDancer.DIRECTIONALPHA * primaryDirection.y + (1 - InteractiveDancer.DIRECTIONALPHA) * d.y)
            if (dd.length >= InteractiveDancer.DIRECTIONTHRESHOLD) {
              let a1 = tx.angle
              let a2 = atan2(dd.y, dd.x)
              tx = tx * Matrix(angle: a2 - a1)
              primaryDirection = dd
            }
          }
        }
        primaryTouch = primaryMove
      }

      if (secondaryMove !== InteractiveDancer.NOPOINT) {
        //  Rotation follow right finger
        //  Get the vector of the user's finger
        let dx = -(secondaryMove.x - secondaryTouch.x) * InteractiveDancer.ANGLESENSITIVITY
        let dy = (secondaryMove.y - secondaryTouch.y) * InteractiveDancer.ANGLESENSITIVITY
        let vf = Vector(dx, dy)
        //  Get the vector the dancer is facing
        let vu = Matrix(tx).direction
        //  Amount of rotation is z of the cross product of the two
        let da = vu.crossZ(vf)
        tx = tx * Matrix(angle: da)
        secondaryTouch = secondaryMove
      }

    }
  }

  func touchDown(_ m:UITouch, x:Double, y:Double) {
    //  Figure out if touching left or right side, and remember the point
    //  Also need to remember the "id" to correlate future move events
    //  Point has already been transformed to dancer coords
    if ((y < 0) ^ primaryIsLeft) {
      primaryTouch = Vector(x,y)
      primaryMove = primaryTouch
      primaryid = m
    } else {
      secondaryTouch = Vector(x,y)
      secondaryMove = secondaryTouch
      secondaryid = m
    }
  }

  func touchUp(_ m:UITouch) {
    if (m == primaryid) {
      primaryTouch = InteractiveDancer.NOPOINT
      primaryMove = InteractiveDancer.NOPOINT
      primaryid = nil
    } else if (m == secondaryid) {
      secondaryTouch = InteractiveDancer.NOPOINT
      secondaryMove = InteractiveDancer.NOPOINT
      secondaryid = nil
    }
  }

  func touchMove(_ m:UITouch, x:Double, y:Double) {
    if (m ==  primaryid) {
      primaryMove = Vector(x,y)
    } else if (m == secondaryid) {
      secondaryMove = Vector(x,y)
    }
  }

}

