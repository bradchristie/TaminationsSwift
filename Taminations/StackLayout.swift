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

class StackLayout : ViewGroup {

  @discardableResult
  override func appendView(_ child:View) -> View {
    return super.appendView(child).fillParent()
  }

  override func layoutChildren() {
    super.layoutChildren()
    children.filter({!$0.div.isHidden }).forEach { child in
      alignEdge(child,.top,self,.top)
      alignEdge(child,.bottom,self,.bottom)
      alignEdge(child,.left,self,.left)
      alignEdge(child,.right,self,.right)
    }
  }
}
