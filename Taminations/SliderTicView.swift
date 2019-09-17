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

class SliderTicView : Canvas {

  private var beats = 0.0
  private var parts:[Double] = []
  private var isParts = false
  private var isCalls = false
  private var p = DrawingStyle(color:UIColor.white, textAlign:.TOP, lineWidth:1.0)

  override func onDraw(_ ctx: DrawingContext) {
    let myleft = 15.pp.d
    let mywidth = width.d - 30.pp.d
    //  Draw background
    ctx.fillRect(rect: CGRect(x: 0, y: 0, width: width, height: height),
      p: DrawingStyle(color:UIColor.TICS))
    if (beats > 4.0) {
      //  Draw tic marks
      for loc in 1 ..< beats.i {
        let x = myleft + mywidth*loc.d/beats
        ctx.drawLine(x1: x, y1: 0.0, x2: x, y2: height.d/4.0, p)
      }
      //  Draw Start and End labels
      let y = height.d * 2.0 / 8.0
      let x1 = myleft + mywidth * 2.0 / beats
      p.textSize = height.d/1.5
      ctx.fillText("Start",x:x1,y:y,p)
      let x2 = myleft + mywidth * (beats - 2.0) / beats
      ctx.fillText("End",x:x2,y:y,p)
      //  Draw parts
      if (!parts.isEmpty) {
        let denom = (parts.count + 1).s
        for i in parts.indices {
          if (parts[i] < beats-4) {
            let x = myleft + mywidth * (2.0 + parts[i]) / beats
            let text = (isParts && i == 0) ? "Part 2"
            : (isParts||isCalls) ? (i+2).s
            : (i+1).s + "/" + denom
            ctx.fillText(text, x:x, y:y, p)
          }
        }
      }
    }
  }

  //  Set the type and values of the tic marks
  func setTics(_ b:Double, partstr:String, isParts:Bool=false, isCalls:Bool=false) {
    beats = b
    self.isParts = isParts
    self.isCalls = isCalls
    parts = []
    if (!partstr.isEmpty) {
      //  The partstr is a list of the length of each part except the last one
      //  We want to show the beat count at each point so will sum the part lengths
      //  for each
      var s = 0.0
      partstr.split(";").forEach { p in
        let pd = p.d
        parts.append(pd + s)
        s += pd
      }
    }
    invalidate()
  }

}
