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

class SpinTheWindmill : Action {

  override var level:LevelData { return LevelObject.find("a2") }
  override var requires:[String] { return ["b2/trade","b2/ocean_wave","a2/slip","b1/face",
                                           "ms/cast_off_three_quarters","a2/spin_the_windmill"] }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    var prefix = ""
    //  Get the center 4 dancers
    //  Note that if tidal it's not the same as the "centers"
    let centers = ctx.center(4)
    //  Step to a wave if facing couples
    let ctxCenters = CallContext(ctx, centers)
    ctxCenters.analyze()
    let wave = (norm.startsWith("left")) ? "Left-Hand Wave" : "Wave"
    if (ctxCenters.dancers.all { d in
      ctxCenters.isInCouple(d)
    }) {
      prefix = "Step to a \(wave)"
    }
    //  Then Swing, Slip, Cast
    let centerPart = "Center 4 \(prefix) Trade Slip Cast Off 3/4"

    let outerPart = "Outer 4 _Windmill "+norm.replaceFirst(".*windmill","")

    try ctx.applyCalls("\(outerPart) while \(centerPart)")
  }
}

class Windmillx : Action {
  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Get the direction
    let dir = norm.replace("_windmill","")
    //  Face that way and do two circulates
    if (dir == "forward") {
      try ctx.applyCalls("Circulate", "Circulate")
    } else {
      try ctx.applyCalls("Face \(dir)", "Circulate", "Circulate")
    }
  }
}