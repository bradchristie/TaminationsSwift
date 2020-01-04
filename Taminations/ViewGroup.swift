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

class ViewGroup : View {

  var children:[View] = []
  var suspendLayout = false

  @discardableResult
  func appendView(_ child:View) -> View {
    div.addSubview(child.div)
    children.append(child)
    child.parent = self
    if (!suspendLayout) {
      layoutChildren()
    }
    return child
  }

  func removeView(_ child:View) {
    child.parent = nil
    child.div.removeFromSuperview()
    children.remove(at: children.firstIndex(where: { $0===child } )!)
    layoutChildren()
  }

  func clear() {
    children.forEach { child in
      child.parent = nil
      child.div.removeFromSuperview()
    }
    children.removeAll()
  }

  //  Find first descendent that satisfies a predicate
  func findChildThat(_ f:(View)->Bool) -> View? {
    var retval:View? = nil
    children.forEach { child in
      if (retval == nil) {
        if (f(child)) {
          retval = child
        }
        else if let childgroup = child as? ViewGroup {
          retval = childgroup.findChildThat(f)
        }
      }
    }
    return retval
  }

  override func layoutChildren() {
    super.layoutChildren()
    children.forEach { child in
      child.layoutChildren()
    }
    suspendLayout = false
  }  //  implemented in inherited classes with specific layouts

  func alignEdge(_ child:View, _ edge1:NSLayoutConstraint.Attribute,
                 _ to:View, _ edge2:NSLayoutConstraint.Attribute) {
    var m = 0
    switch (edge1) {
      case .left : m = child.leftMargin
      case .right : m = -child.rightMargin
      case .top : m = child.topMargin
      case .bottom : m = -child.bottomMargin
      default : break
    }
    NSLayoutConstraint(item:child.div,attribute:edge1,relatedBy: .equal,
      toItem: to.div, attribute: edge2, multiplier: 1, constant: m.cg).isActive = true
  }

  func alignCenter(_ child:View) {
    NSLayoutConstraint(item: child.div, attribute: .centerY,
      relatedBy: .equal, toItem: div, attribute: .centerY, multiplier: 1, constant: (child.topMargin-child.bottomMargin).cg).isActive = true
  }

  func alignMiddle(_ child:View) {
    NSLayoutConstraint(item: child.div, attribute: .centerX,
      relatedBy: .equal, toItem: div, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
  }

}
