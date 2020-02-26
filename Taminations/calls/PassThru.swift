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

class PassThru : Action {

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    //  If in wave then maybe Ocean Wave rule applies
    let isFacing = ctx.dancerFacing(d)?.data.active ?? false
    if (!isFacing && ctx.isInWave(d)) {
      var d2 = d.data.partner!
      if (!d2.data.active) {
        let d3 = d2.isRightOf(d) ? ctx.dancerToLeft(d) : ctx.dancerToRight(d)
        if (d3 != nil) {
          d2 = d3!
        }
      }
      if (d2.data.active) {
        let dist = d.distanceTo(d2)
        if (norm.startsWith("left")) {
          if (d2.isLeftOf(d)) {
            return TamUtils.getMove("Extend Left").scale(1.0,dist/2.0)
          }
        } else if (d2.isRightOf(d)) {
          return TamUtils.getMove("Extend Right").scale(1.0,dist/2.0)
        }
      }
    }
    //  Can only pass thru with another dancer
    //  in front of this dancer
    //  who is also facing this dancer
    guard let d2 = ctx.dancerFacing(d) else {
      return try ctx.dancerCannotPerform(d, name)
    }
    if (!d2.data.active) {
      throw CallError("Dancers must Pass Thru with each other")
    }
    let dist = d.distanceTo(d2)
    return (norm.startsWith("left"))
      ? TamUtils.getMove("Extend Right").scale(dist/2,0.5) +
        TamUtils.getMove("Extend Left").scale(dist/2,0.5)
      : TamUtils.getMove("Extend Left").scale(dist/2,0.5) +
        TamUtils.getMove("Extend Right").scale(dist/2,0.5)
  }
}
