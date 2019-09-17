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

class HeadsSides : FilterActives {

  private var square = false

  override func performCall(_ ctx: CallContext, _ index: Int) throws {
    square = ctx.isSquare()
    try super.performCall(ctx, index)
  }

  override func isActive(_ d: Dancer) -> Bool {
    if (square && norm == "head") { return d.location.x.abs.isApprox(3.0) }
    else if (square && norm == "side") { return d.location.y.abs.isApprox(3.0) }
    else if (norm == "head") { return  d.number_couple == "1" || d.number_couple == "3" }
    else if (norm == "side") { return d.number_couple == "2" || d.number_couple == "4" }
    else { return false }
  }
  
}
