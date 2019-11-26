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

class Path {

  var movelist:[Movement] = []
  private var transformlist:[Matrix] = []

  convenience init(_ moves:[Movement]) {
    self.init()
    movelist = moves
    recalculate()
  }

  convenience init(_ m:Movement) {
    self.init([m])
  }

  convenience init(_ p:Path) {
    self.init(p.movelist)
  }

  func recalculate() {
    var tx = Matrix()
    transformlist = movelist.map { it in
      tx = tx * it.translate() * it.rotate()
      return Matrix(tx)
    }
  }

  func clear() {
    movelist.removeAll()
    transformlist.removeAll()
  }

  @discardableResult
  func add(_ p:Path) -> Path {
    movelist.append(contentsOf: p.movelist)
    recalculate()
    return self
  }

  static func +(left: Path, right: Path) -> Path {
    let p = Path(left)
    p.add(right)
    return p
  }

  static func +=(left: inout Path, right: Path) {
    left.add(right)
  }

  @discardableResult
  func add(_ m:Movement) -> Path {
    movelist.append(m)
    recalculate()
    return self
  }

  @discardableResult
  func pop() -> Movement {
    let m = movelist.removeLast()
    recalculate()
    return m
  }

  func reflect() -> Path {
    movelist = movelist.map { it in it.reflect() }
    recalculate()
    return self
  }

  var beats:Double { get { return movelist.reduce(0.0, { $0 + $1.beats} ) } }

  @discardableResult
  func changebeats(_ newbeats:Double) -> Path {
    let factor = newbeats / beats
    movelist = movelist.map { it in it.time(it.beats*factor) }
    //  no need to recalculate, transformlist doesn't depend on beats
    return self
  }

  @discardableResult
  func changehands(_ hands:Hands) -> Path {
    movelist = movelist.map { it in it.useHands(hands) }
    return self
  }

  @discardableResult
  func scale(_ x:Double, _ y:Double) -> Path {
    movelist = movelist.map { it in it.scale(x,y) }
    recalculate()
    return self
  }

  @discardableResult
  func skew(_ x:Double, _ y:Double) -> Path {
    if (!movelist.isEmpty) {
      //  Apply the skew to just the last movement
      movelist.append(movelist.removeLast().skew(x,y))
      recalculate()
    }
    return self
  }

  @discardableResult
  func skewFirst(_ x:Double, _ y:Double) -> Path {
    if (!movelist.isEmpty) {
      movelist = [movelist.first!.skew(x,y)] + movelist.dropFirst()
      recalculate()
    }
    return self
  }

  func notFromCall() -> Path {
    movelist.forEach { m in m.fromCall = false }
    return self
  }

  /**
   * Return a transform for a specific point of time
   */
  func animate(_ b:Double) -> Matrix {
    var bv = b
    var tx = Matrix()
    //  Apply all completed movements
    var m:Movement?
    for i in movelist.indices {
      m = movelist[i]
      if (bv >= m!.beats) {
        tx = transformlist[i]
        bv -= m!.beats
        m = nil
      } else {
        break
      }
    }
    //  Apply movement in progress
    if (m != nil) {
      tx = tx * m!.translate(bv) * m!.rotate(bv)
    }
    return tx
  }

  /**
   * Return the current hand at a specific point in time
   */
  func hands(_ b:Double) -> Hands {
    if (b < 0 || b > beats) {
      return .BOTHHANDS
    }
    var bv = b
    return movelist.reduce(Hands.BOTHHANDS) { (h:Hands,m:Movement) -> Hands in
      if (bv < 0) {
        return h
      }
      bv = bv - m.beats
      return m.hands
    }

  }

}
