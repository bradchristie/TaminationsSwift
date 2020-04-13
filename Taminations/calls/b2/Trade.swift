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

class Trade : Action {

  override var level:LevelData { return LevelObject.find("b2") }

  init() {
    super.init("Trade")
  }

  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    //  Figure out what dancer we're trading with
    var leftcount = 0
    var bestleft: Dancer? = nil
    var rightcount = 0
    var bestright: Dancer? = nil
    ctx.actives.forEach { d2 in
      if (d2 != d) {
        if (d2.isLeftOf(d)) {
          if (leftcount == 0 || d.distanceTo(d2) < d.distanceTo(bestleft!)) {
            bestleft = d2
          }
          leftcount += 1
        } else if (d2.isRightOf(d)) {
          if (rightcount == 0 || d.distanceTo(d2) < d.distanceTo(bestright!)) {
            bestright = d2
          }
          rightcount += 1
        }
      }
    }

    //  Check that the trading dancer is facing same or opposite direction
    if (bestright != nil && !d.isRightOf(bestright!) && !d.isLeftOf(bestright!)) {
      bestright = nil
    }
    if (bestleft != nil && !d.isRightOf(bestleft!) && !d.isLeftOf(bestleft!)) {
      bestleft = nil
    }

    var dtrade = d
    var samedir = true
    var call = ""
    //  We trade with the nearest dancer in the direction with
    //  an odd number of dancers
    if (bestright != nil && ((rightcount % 2 == 1 && leftcount % 2 == 0) || bestleft == nil)) {
      dtrade = bestright!
      call = "Run Right"
      samedir = d.isLeftOf(dtrade)
    } else if (bestleft != nil && ((rightcount % 2 == 0 && leftcount % 2 == 1) || bestright == nil)) {
      dtrade = bestleft!
      call = "Run Left"
      samedir = d.isRightOf(dtrade)
    }
    //  else throw error
    else {
      throw CallError("Unable to calculate Trade")
    }

    //  Found the dancer to trade with.
    //  Now make room for any dancers in between
    var hands = Hands.NOHANDS
    let dist = d.distanceTo(dtrade)
    var scaleX = 1.0
    if (ctx.inBetween(d,dtrade).isNotEmpty()) {
      //  Intervening dancers
      //  Allow enough room to get around them and pass right shoulders
      if (call == "Run Right" && samedir) {
        scaleX = 2.0
      }
    } else {
      //  No intervening dancers
      if (call == "Run Left" && samedir) {
        //  Partner trade, flip the belle
        call = "Flip Left"
      } else {
        scaleX = dist / 2
      }
      //  Hold hands for trades that are swing/slip
      if (!samedir && dist < 2.1) {
        hands = (call == "Run Left") ? .LEFTHAND : .RIGHTHAND
      }
    }
    return TamUtils.getMove(call).changehands(hands).scale(scaleX,dist/2)

  }


}
