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

class Face : Action {

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    var move = ""
    switch (norm) {
      case "facein" : move = d.angleToOrigin < 0 ? "Quarter Right" : "Quarter Left"
      case "faceout" : move = d.angleToOrigin > 0 ? "Quarter Right" : "Quarter Left"
      case "faceleft" : move = "Quarter Left"
      case "faceright" : move = "Quarter Right"
      default : throw CallError("Internal error in Face <direction>")
    }
    return TamUtils.getMove(move)
  }

}
