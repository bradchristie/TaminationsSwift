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

class Canvas : View {

  class CanvasDiv : UIView {

    var canvas:Canvas?

    override func draw(_ rect: CGRect) {
      canvas?.onDraw(DrawingContext(UIGraphicsGetCurrentContext()!))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      touches.forEach { touch in
        let point = touch.location(in:self)
        canvas?.touchDownCode(touch,point.x.i,point.y.i)
      }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      touches.forEach { touch in
        let point = touch.location(in:self)
        canvas?.touchMoveCode(touch,point.x.i,point.y.i)
      }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      touches.forEach { touch in
        let point = touch.location(in:self)
        canvas?.touchUpCode(touch,point.x.i,point.y.i)
      }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
      //  Could be cancelled because it's really a long press
      //  So don't do touchedEnded (i.e. touchUp)
      // touchesEnded(touches, with: event)
    }
  }

  /*  private  */ let mydiv = CanvasDiv()

   init() {
    super.init(mydiv)
    mydiv.translatesAutoresizingMaskIntoConstraints = false
    mydiv.canvas = self
  }

  //  This is overridden by subclasses
  func onDraw(_ ctx:DrawingContext) { }

  override func invalidate() {
    mydiv.setNeedsDisplay()
  }

  override func layoutChildren() {
    super.layoutChildren()
    invalidate()
  }
}
