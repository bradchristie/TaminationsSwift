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

class MikeShape : Shape {

  //  Use a changeable color to show when recording is active
  var color:UIColor = UIColor.black

  override func draw(ctx: DrawingContext, bounds: CGRect) {
    let s = bounds.height.d / 250.0
    let myp = DrawingStyle()
    myp.color = color
    //  Body of mike
    ctx.fillCircle(x:s*128,y:s*60,radius:s*24,p:myp)
    ctx.fillCircle(x:s*128,y:s*120,radius:s*24,p:myp)
    ctx.fillRect(rect:CGRect(x:104*s,y:60*s,width:48*s,height:60*s),p:myp)

    //  Mike support
    myp.lineWidth = 12*s
    let path = DrawingPath()
    path.arc(x:128*s,y:120*s,radius:48*s, startAngle:.pi,endAngle:0.0)
    ctx.drawPath(path,myp)
    ctx.fillRect(rect:CGRect(x:120*s,y:170*s,width:16*s,height:30*s),p:myp)
  }
}
