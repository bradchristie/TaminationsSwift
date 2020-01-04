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

class Logo : Shape {

  override func draw(ctx: DrawingContext, bounds: CGRect) {

    let range = min(bounds.width.d,bounds.height.d)
    ctx.scale(range/175.0,range/175.0)
    let p = DrawingStyle(lineWidth: 4.0)

    //  Handhold
    p.color = UIColor.orange
    ctx.fillCircle(x:88.0,y:88.0,radius:9.0,p:p)
    ctx.drawLine(x1:62.0,y1:88.0,x2:138.0,y2:88.0,p)

    //  Boy
    p.color = UIColor.blue.darker()
    ctx.fillCircle(x:37.0,y:60.0,radius:15.0,p:p)
    p.color = UIColor.blue
    ctx.fillRect(rect:CGRect(x:11.0,y:61.0,width:52.0,height:52.0),p:p)
    p.color = UIColor.blue.darker()
    ctx.drawRect(rect:CGRect(x:11.0,y:61.0,width:52.0,height:52.0),p:p)

    //  Girl
    p.color = UIColor.red.darker()
    ctx.fillCircle(x:138.0,y:114.0,radius:15.0,p:p)
    p.color = UIColor.red
    ctx.fillCircle(x:138.0,y:87.0,radius:26.0,p:p)
    p.color = UIColor.red.darker()
    ctx.drawCircle(x:138.0,y:87.0,radius:26.0,p:p)
  }

}
