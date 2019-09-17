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

func ieeeRemainder(_ x:Double,_ y:Double) -> Double {
  return x - round(x/y)*y
}

struct Handhold {

  let dancer1:Dancer
  let dancer2:Dancer
  let hold1:Hands
  let hold2:Hands
  let angle1:Double
  let angle2:Double
  let distance:Double
  let score:Double

  func inCenter() -> Bool {
    return dancer1.inCenter && dancer2.inCenter
  }

  static func apply(_ d1:Dancer, _ d2:Dancer, geometry:GeometryType) -> Handhold? {
    guard !d1.hidden && !d2.hidden else {
      return nil
    }
    //  Turn off grips if not specified in current movement
    if ((d1.hands.i & Hands.GRIPRIGHT.i) != Hands.GRIPRIGHT.i) {
      d1.rightgrip = nil
    }
    if ((d1.hands.i & Hands.GRIPLEFT.i) != Hands.GRIPLEFT.i) {
      d1.leftgrip = nil
    }
    if ((d2.hands.i & Hands.GRIPRIGHT.i) != Hands.GRIPRIGHT.i) {
      d2.rightgrip = nil
    }
    if ((d2.hands.i & Hands.GRIPLEFT.i) != Hands.GRIPLEFT.i) {
      d2.leftgrip = nil
    }

    //  Check distance
    let x1 = d1.tx.m31
    let y1 = d1.tx.m32
    let x2 = d2.tx.m31
    let y2 = d2.tx.m32
    let dx = x2 - x1
    let dy = y2 - y1
    let dfactor1 = 0.1  // for distance up to 2.0
    let dfactor2 = 2.0  // for distance past 2.0
    let cutover = geometry==GeometryType.HEXAGON ? 2.5 : geometry==GeometryType.BIGON ? 3.7 : 2.0
    let d = sqrt(dx*dx + dy*dy)
    let dfactor0 = geometry==GeometryType.HEXAGON ? 1.15 : 1.0
    let d0 = d * dfactor0
    var score1 = d0 > cutover ? (d0-cutover)*dfactor2+2*dfactor1 : d0*dfactor1
    var score2 = score1
    //  Angle between dancers
    let a0 = atan2(dy,dx)
    //  Angle each dancer is facing
    let a1 = atan2(d1.tx.m12,d1.tx.m22)
    let a2 = atan2(d2.tx.m12,d2.tx.m22)
    //  For each dancer, try left and right hands
    var h1 = Hands.NOHANDS
    var h2 = Hands.NOHANDS
    var ah1 = 0.0
    var ah2 = 0.0
    let afactor1 = 0.2
    let afactor2 = geometry == GeometryType.BIGON ? 0.6 : 1.0

    //  Dancer 1
    var a = abs(ieeeRemainder(abs(a1-a0 + .pi * 3.0/2.0), .pi * 2))
    var ascore = a >  .pi / 6 ? (a - .pi / 6) * afactor2 + .pi / 6 * afactor1 : a * afactor1
    if (score1+ascore < 1.0 && (d1.hands.i & Hands.RIGHTHAND.i) != Hands.NOHANDS.i && d1.rightgrip==nil || d1.rightgrip == d2) {
      score1 = d1.rightgrip == d2 ? 0 : score1 + ascore
      h1 = Hands.RIGHTHAND
      ah1 = a1 - a0 + .pi * 3.0/2.0
    } else {
      a = abs(ieeeRemainder(abs(a1 - a0 + .pi / 2), .pi * 2))
      ascore = a >  .pi / 6 ? (a - .pi / 6) * afactor2 + .pi / 6 * afactor1 : a * afactor1
      if (score1+ascore < 1.0 && (d1.hands.i & Hands.LEFTHAND.i) != Hands.NOHANDS.i && d1.leftgrip==nil || d1.leftgrip==d2) {
        score1 = d1.leftgrip==d2 ? 0.0 : score1 + ascore
        h1 = Hands.LEFTHAND
        ah1 = a1 - a0 + .pi / 2
      } else {
        score1 = 10.0
      }
    }

    //  Dancer 2
    a = abs(ieeeRemainder(abs(a2 - a0 + .pi / 2), .pi * 2))
    ascore = a >  .pi / 6 ? (a - .pi / 6) * afactor2 + .pi / 6 * afactor1 : a * afactor1
    if (score2+ascore < 1.0 && (d2.hands.i & Hands.RIGHTHAND.i) != Hands.NOHANDS.i && d2.rightgrip==nil || d2.rightgrip == d1) {
      score2 = d2.rightgrip == d1 ? 0 : score2 + ascore
      h2 = Hands.RIGHTHAND
      ah2 = a2 - a0 + .pi / 2
    } else {
      a = abs(ieeeRemainder(abs(a2 - a0 + .pi * 3.0/2.0), .pi * 2))
      ascore = a >  .pi / 6 ? (a - .pi / 6) * afactor2 + .pi / 6 * afactor1 : a * afactor1
      if (score2+ascore < 1.0 && (d2.hands.i & Hands.LEFTHAND.i) != Hands.NOHANDS.i && d2.leftgrip==nil || d2.leftgrip==d1) {
        score2 = d2.leftgrip==d1 ? 0.0 : score2 + ascore
        h2 = Hands.LEFTHAND
        ah2 = a2 - a0 + .pi * 3.0/2.0
      } else {
        score2 = 10.0
      }
    }

    //  Generate return value
    if (d1.rightgrip == d2 && d2.rightgrip == d1) {
      return Handhold(dancer1: d1, dancer2: d2, hold1: Hands.RIGHTHAND, hold2: Hands.RIGHTHAND, 
        angle1: ah1, angle2: ah2, distance: d, score: 0)
    } else if (d1.rightgrip == d2 && d2.leftgrip == d1) {
      return Handhold(dancer1: d1, dancer2: d2, hold1: Hands.RIGHTHAND, hold2: Hands.LEFTHAND, 
        angle1: ah1, angle2: ah2, distance: d, score: 0)
    } else if (d1.leftgrip == d2 && d2.rightgrip == d1) {
      return Handhold(dancer1: d1, dancer2: d2, hold1: Hands.LEFTHAND, hold2: Hands.RIGHTHAND, 
        angle1: ah1, angle2: ah2, distance: d, score: 0)
    } else if (d1.leftgrip == d2 && d2.leftgrip == d1) {
      return Handhold(dancer1: d1, dancer2: d2, hold1: Hands.LEFTHAND, hold2: Hands.LEFTHAND, 
        angle1: ah1, angle2: ah2, distance: d, score: 0)
    } else if (score1 > 1 || score2 > 1 || score1 + score2 > 1.2) {
      return nil
    }
    return Handhold(dancer1: d1, dancer2: d2, hold1: h1, hold2: h2, angle1: ah1, angle2: ah2, distance: d, score: score1+score2)
  }

}

