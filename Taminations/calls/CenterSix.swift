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

class CenterSix : CodedCall {

  init() {
    super.init("Center 6")
  }

  override func performCall(_ ctx: CallContext, _ index: Int) throws {
    let dorder = ctx.dancers.sorted { (d1,d2) in d1.location.length < d2.location.length }
    if (!dorder[5].location.length.isApprox(dorder[6].location.length)) {
      dorder.dropFirst(6).forEach { d in d.data.active = false }
    }
    else {
      //  Maybe the outer of the 6 is just a little further than the other 2
      if (!dorder[3].location.length.isApprox(dorder[4].location.length) &&
        dorder[4].location.length - dorder[3].location.length < 0.5) {
        dorder[2].data.active = false
        dorder[3].data.active = false
      } else {
        //  Could not separate 6 dancers from other 2
        throw CallError("Cannot find 6 dancers in center")        
      }
    }

  }

}
