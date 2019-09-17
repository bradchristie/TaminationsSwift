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

class RelativeLayout : ViewGroup {

  override func layoutChildren() {
    super.layoutChildren()
    children.filter({!$0.div.isHidden }).forEach { child in
      if (child.align & Align.Top != 0) {
        alignEdge(child,.top,self,.top)
      }
      if (child.align & Align.Bottom != 0) {
        alignEdge(child,.bottom,self,.bottom)
      }
      if (child.align & Align.Left != 0) {
        alignEdge(child,.left,self,.left)
      }
      if (child.align & Align.Right != 0) {
        alignEdge(child,.right,self,.right)
      }
    }
  }


}
