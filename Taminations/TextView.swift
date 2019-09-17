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

class TextView : View {

  //  The UILabel class does not use its margins
  //  so we need to do it ourselves
  class TextLabel : UILabel {
    //override func drawText(in rect: CGRect) {
    //  super.drawText(in: rect.inset(by: layoutMargins))
    //}

    override var intrinsicContentSize: CGSize {
      let rawsize = super.intrinsicContentSize
      return CGSize(
        width: rawsize.width+layoutMargins.left+layoutMargins.right,
        height: rawsize.height+layoutMargins.top+layoutMargins.bottom)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
      let fit = super.sizeThatFits(size)
      //  need to set this or text won't wrap
      preferredMaxLayoutWidth = fit.width
      return CGSize(
        width: fit.width + layoutMargins.left + layoutMargins.right,
        height: fit.height + layoutMargins.top + layoutMargins.bottom)
    }
  }

  private let mydiv = TextLabel()
  private var fontSize = 20
  private var bold = ""

  init() {
    mydiv.translatesAutoresizingMaskIntoConstraints = false
    super.init(mydiv)
  }
  convenience init(_ text:String) {
    self.init()
    self.text = text
    mydiv.font = UIFont.preferredFont(forTextStyle: .body)
  }

  var autoSize:Bool {
    get { return mydiv.adjustsFontSizeToFitWidth }
    set {
      mydiv.adjustsFontSizeToFitWidth = newValue
      mydiv.minimumScaleFactor = 0.1
      mydiv.numberOfLines = 0
    }
  }

  var textStyle:String {
    get { fatalError() }
    set { if (newValue == "bold") {
      mydiv.font = UIFont(name:"Helvetica Bold",size:fontSize.cg)
      bold = " Bold"
    } }
  }

  var textSize:Int {
    get { return fontSize }
    set {
      fontSize = newValue
      mydiv.font = UIFont(name:mydiv.font.fontName,size:fontSize.cg)
    }
  }

  override var textColor:UIColor {
    get { return mydiv.textColor }
    set { mydiv.textColor = newValue }
  }

  func nowrap() {
    mydiv.numberOfLines = 1
  }
  func wrap() {
    mydiv.numberOfLines = 0
    mydiv.lineBreakMode = .byWordWrapping
  }

  //  If the text does not fit its space, reduce font size and check again
  private func recursivelyFitTextToBounds() {
    let cw = mydiv.bounds.width
    let ch = mydiv.bounds.height
    let fit = mydiv.sizeThatFits(mydiv.bounds.size)
    let tw = fit.width
    let th = fit.height
    //  Don't let font get microscopic
    if (cw > 0 && ch > 0 && (tw > cw || th > ch) && mydiv.font.pointSize > 4) {
      //  Set new font size
      let newSize = mydiv.font.pointSize - 1
      mydiv.font = UIFont(name: mydiv.font.fontName, size: newSize)
      //  Let system catch up and check again
      Application.later {
        self.recursivelyFitTextToBounds()
      }
    }
  }

  //  Set font size to user-requested size, then
  //  reduce as needed to fit its space
  func fitTextToBounds() {
    //div.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    //  First reset ti user-requested size, might have been reduced
    //  by previous call
    mydiv.font = UIFont(name:mydiv.font.fontName, size:fontSize.cg)
    //  Give the system a chance to calculate its new space,
    //  then fit to it
    Application.later {
      self.recursivelyFitTextToBounds()
    }
  }

  //  Text shadow is only used for the title bar
  func shadow() {
    mydiv.shadowColor = UIColor.black
    mydiv.shadowOffset = CGSize(width:1,height:1)
  }

  var text:String {
    get { return mydiv.text ?? "" }
    set { mydiv.text = newValue }
  }

  //  Text alignment - also often done by alignment of this view in its parent
  @discardableResult
  override func alignMiddle() -> View {
    mydiv.textAlignment = .center
    return super.alignMiddle()
  }

  override func alignRight() -> View {
    mydiv.textAlignment = .right
    return super.alignRight()
  }
}
