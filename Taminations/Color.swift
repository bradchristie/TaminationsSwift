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

extension Int {
  var uiColor:UIColor { get { return UIColor(red: ((self & 0xff0000) >> 16).cg/255,
                                             green: ((self & 0x00ff00) >> 8).cg/255,
                                             blue: (self & 0x0000ff).cg/255,
                                             alpha: 1)} }
}

extension UIColor {

  static var BMS:UIColor { get { return 0xc0c0ff.uiColor } }
  static var B1:UIColor { get { return 0xe0e0ff.uiColor } }
  static var B2:UIColor { get { return 0xe0e0ff.uiColor } }
  static var MS:UIColor { get { return 0xe0e0ff.uiColor } }
  static var PLUS:UIColor { get { return 0xc0ffc0.uiColor } }
  static var ADV:UIColor { get { return 0xffe080.uiColor } }
  static var A1:UIColor { get { return 0xfff0c0.uiColor } }
  static var A2:UIColor { get { return 0xfff0c0.uiColor } }
  static var CHALLENGE:UIColor { get { return 0xffc0c0.uiColor } }
  static var C1:UIColor { get { return 0xffe0e0.uiColor } }
  static var C2:UIColor { get { return 0xffe0e0.uiColor } }
  static var C3A:UIColor { get { return 0xffe0e0.uiColor } }
  static var C3B:UIColor { get { return 0xffe0e0.uiColor } }
  static var COMMON:UIColor { get { return 0xc0ffc0.uiColor } }
  static var HARDER:UIColor { get { return 0xffffc0.uiColor } }
  static var EXPERT:UIColor { get { return 0xffc0c0.uiColor } }
  static var FLOOR:UIColor { get { return 0xfff0e0.uiColor } }
  static var TICS:UIColor { get { return 0x008000.uiColor } }
  static var SEPARATOR:UIColor { get { return 0x804080.uiColor } }

  static func colorForName(_ name:String) -> UIColor {
    switch (name.lowercased()) {
      case "black" : return UIColor.black
      case "blue" : return UIColor.blue
      case "cyan" : return UIColor.cyan
      case "gray" : return UIColor.gray
      case "green" : return UIColor.green
      case "magenta" : return UIColor.magenta
      case "orange" : return UIColor.orange
      case "red" : return UIColor.red
      case "white" : return UIColor.white
      case "yellow" : return UIColor.yellow
      default : return UIColor.white
    }
  }

  private func colors() -> (CGFloat,CGFloat,CGFloat) {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return (red,green,blue)
  }

  func darker(_ f:Double = 0.7) -> UIColor {
    let (red,green,blue) = colors()
    return UIColor(red: red*f.cg, green: green*f.cg, blue: blue*f.cg, alpha: 1)
  }

  private func invert() -> UIColor {
    let (red,green,blue) = colors()
    return UIColor(red: 1.0-red, green: 1.0-green, blue: 1.0-blue, alpha: 1)
  }

  func brighter(_ f:Double = 0.7) -> UIColor {
    return invert().darker(f).invert()
  }
  func veryBright() -> UIColor { return brighter(0.25) }
}
