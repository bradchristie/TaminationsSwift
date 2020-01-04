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

extension Matrix {

  var cg:CGAffineTransform { get {
    return CGAffineTransform(a: m11.cg, b: m12.cg, c: m21.cg, d: m22.cg, tx: m31.cg, ty: m32.cg)
  } }

}

enum TextAlign {
  case TOPLEFT
  case TOP
  case TOPRIGHT
  case LEFT
  case CENTER
  case RIGHT
  case BOTTOMLEFT
  case BOTTOM
  case BOTTOMRIGHT
}

class DrawingStyle {
  var color:UIColor
  var alpha:Double
  var textSize:Double
  var textAlign:TextAlign
  var lineWidth:Double
  init(color:UIColor=UIColor.black,alpha:Double=1.0,textSize:Double=10.0,
       textAlign:TextAlign=(.LEFT),lineWidth:Double=1.0) {
    self.color = color
    self.alpha = alpha
    self.textSize = textSize
    self.textAlign = textAlign
    self.lineWidth = lineWidth
  }
}

class DrawingPath {
  let path = UIBezierPath()
  func moveTo(_ x:Double, _ y:Double) {
    path.move(to:CGPoint(x: x, y: y))
  }

  func lineTo(_ x:Double, _ y:Double ) {
    path.addLine(to: CGPoint(x: x, y: y))
  }

  func arc(x: Double, y:Double, radius: Double, startAngle:Double, endAngle:Double) {
    path.addArc(withCenter: CGPoint(x:x,y:y), radius: radius.cg, startAngle: startAngle.cg, endAngle: endAngle.cg, clockwise: false)
  }

  func close () {
    path.close()
  }

}

class DrawingContext {

  private let ctx:CGContext

  init(_ ctx:CGContext) {
    self.ctx = ctx
  }

  var width:Int { return ctx.width }
  var height:Int { return ctx.height }

  private func style(_ p:DrawingStyle) {
    ctx.setStrokeColor(p.color.cgColor)
    ctx.setFillColor(p.color.cgColor)
    ctx.setAlpha(p.alpha.cg)
    ctx.setLineWidth(p.lineWidth.cg)
  }

  func save() {
    ctx.saveGState()
  }

  func restore() {
    ctx.restoreGState()
  }

  func scale(_ x:Double, _ y:Double) {
    ctx.scaleBy(x: x.cg, y: y.cg)
  }

  func rotate(_ r:Double) {
    ctx.rotate(by: r.cg)
  }

  func translate(_ x:Double, _ y:Double) {
    ctx.translateBy(x: x.cg, y: y.cg)
  }


  func drawCircle(x: Double, y: Double, radius: Double, p: DrawingStyle) {
    style(p)
    ctx.strokeEllipse(in: CGRect(x: x-radius, y: y-radius, width: radius*2, height: radius*2))
  }

  func fillCircle(x: Double, y: Double, radius: Double, p: DrawingStyle) {
    style(p)
    ctx.fillEllipse(in: CGRect(x: x-radius, y: y-radius, width: radius*2, height: radius*2))
  }

  func drawRect(rect:CGRect, p:DrawingStyle) {
    style(p)
    ctx.stroke(rect)
  }

  func fillRect(rect:CGRect, p:DrawingStyle) {
    style(p)
    ctx.fill(rect)
  }

  func drawRoundRect(rect: CGRect, rad: Double, p: DrawingStyle) {
    style(p)
    ctx.addPath(UIBezierPath(roundedRect: rect, cornerRadius: rad.cg).cgPath)
    ctx.strokePath()
  }

  func fillRoundRect(rect: CGRect, rad: Double, p: DrawingStyle) {
    style(p)
    ctx.addPath(UIBezierPath(roundedRect: rect, cornerRadius: rad.cg).cgPath)
    ctx.fillPath()
  }

  func transform(_ m:Matrix) {
    ctx.concatenate(m.cg)
  }

  func fillText(_ text:String, x:Double, y:Double, _ p:DrawingStyle) {
    let attributes = [
      NSAttributedString.Key.foregroundColor: p.color,
      NSAttributedString.Key.font: UIFont(name: "Helvetica", size: p.textSize.cg)!
    ]
    let nstext = text as NSString
    //  CGContext has no mode for aligning text
    //  So we will fake a draw to find the text size and compute the new start
    ctx.setTextDrawingMode(.invisible)
    nstext.draw(at: CGPoint(x: x, y: y), withAttributes: attributes)
    let dx = ctx.textPosition.x.d - x
    //  Sometimes textPosition.y does not change, have not figured that out
    let dy = max(ctx.textPosition.y.d - y, p.textSize+1.0)
    var tx = x
    var ty = y
    switch (p.textAlign) {
      case .TOPLEFT: break
      case .TOP: tx -= dx / 2.0
      case .TOPRIGHT: tx -= dx
      case .LEFT : ty -= dy / 2.0
      case .CENTER : tx -= dx / 2.0 ; ty -= dy / 2.0
      case .RIGHT : tx -= dx ; ty -= dy / 2.0
      case .BOTTOMLEFT : ty -= dy
      case .BOTTOM : ty -= dy ; tx -= dx / 2.0
      case .BOTTOMRIGHT : ty -= dy ; tx -= dx
    }
    ctx.setTextDrawingMode(.fill)
    nstext.draw(at: CGPoint(x: tx, y: ty), withAttributes: attributes)
  }

  func drawLine(x1:Double,y1:Double,x2:Double,y2:Double, _ p:DrawingStyle) {
    style(p)
    ctx.move(to: CGPoint(x:x1,y:y1))
    ctx.addLine(to: CGPoint(x:x2,y:y2))
    ctx.strokePath()
  }

  func drawPath(_ path:DrawingPath, _ p:DrawingStyle) {
    style(p)
    //  UIBezierPath has its own line width setting
    path.path.lineWidth = p.lineWidth.cg
    path.path.stroke()
  }

  func fillPath(_ path:DrawingPath) {
    path.path.fill()
  }


}
