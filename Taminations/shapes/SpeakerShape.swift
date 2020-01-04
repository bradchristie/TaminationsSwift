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

class SpeakerShape : Shape {

  override func draw(ctx: DrawingContext, bounds: CGRect) {
    let h = bounds.height.d/2.0
    let w = h/3.0
    let myp = DrawingStyle()
    ctx.translate(bounds.width.d*0.4,bounds.height.d*0.5)
    ctx.fillRect(rect:CGRect(x:-w*1.5,y:-h*0.33, width:w/2.0, height:h*0.66),p:myp)

    let path = DrawingPath()
    path.moveTo(-w*0.5,-h*0.33)
    path.lineTo(w*0.5,-h*0.7)
    path.lineTo(w*0.5,h*0.7)
    path.lineTo(-w*0.5,h*0.33)
    path.close()
    ctx.fillPath(path)

    let path2 = DrawingPath()
    path2.arc(x:w*0.5,y:0.0,radius:0.5*w,startAngle:.pi*9/4,endAngle:.pi*7/4)
    ctx.drawPath(path2,myp)
    let path3 = DrawingPath()
    path3.arc(x:w*0.5,y:0.0,radius:1.25*w,startAngle:.pi*9/4,endAngle:.pi*7/4)
    ctx.drawPath(path3,myp)
    let path4 = DrawingPath()
    path4.arc(x:w*0.5,y:0.0,radius:2.0*w,startAngle:.pi*9/4,endAngle:.pi*7/4)
    ctx.drawPath(path4,myp)
  }

}
