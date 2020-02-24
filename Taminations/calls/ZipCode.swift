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

class ZipCode : Action {

  override var level: LevelData { LevelObject.find("c2") }
  override var requires:[String] { ["b1/face","b2/run","b1/pass_thru","a1/ends_bend"] }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    guard let count = Int(norm.suffix(1)) else {
      throw CallError("Zip Code how much?")
    }
    try ctx.applyCalls("Centers Face Out")
    ctx.analyze()
    try ctx.applyCalls("Centers Run")
    if (count >= 2) {
      try ctx.applyCalls("Ends Pass Thru")
    }
    if (count >= 3) {
      try ctx.applyCalls("Ends Bend")
    }
    if (count >= 4) {
      try ctx.applyCalls("Ends Pass Thru")
    }
    if (count >= 5) {
      try ctx.applyCalls("Ends Bend")
    }
    if (count >= 6) {
      try ctx.applyCalls("Ends Pass Thru")
    }
  }
}
