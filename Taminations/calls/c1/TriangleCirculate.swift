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

class TriangleCirculate : Action {

  override var level:LevelData { LevelObject.find("c1") }

  //  Calculate circulate path to next triangle dancer
  private func oneCirculatePath(_ d:Dancer, _ d2:Dancer) -> Path {
    if (d2.isInFrontOf(d)) {
      //  Path is forward
      let dist = d.distanceTo(d2)
      return TamUtils.getMove("Forward").scale(dist, 1.0).changebeats(dist)
    }
    if (d2.angleFacing.isAround(d.angleFacing + .pi)) {
      //  Path is 180 degree turn to left or right
      let d2v = d.vectorToDancer(d2)
      return TamUtils.getMove("Run Left")
        .scale(0.5, d2v.y / 2)
        .skew(d2v.x, 0.0)
    } else {
      //  Path is 90 degree turn to left or right
      let d2v = d.vectorToDancer(d2)
      return TamUtils.getMove("Lead Left")
        .scale(d2v.x, d2v.y).changebeats(d2v.length)
    }
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Find the 6 dancers to circulate
    let triangleType = norm.replace("trianglecirculate","")
    let points = ctx.points()
    switch (triangleType) {
      case "inside" : ctx.outer(2).forEach { $0.data.active = false }
      case "outside" : ctx.center(2).forEach { $0.data.active = false }
      case "inpoint" : points.forEach { it in
        if (it.data.leader) {
          it.data.active = false
        }
      }
      case "outpoint" : points.forEach { it in
        if (it.data.trailer) {
          it.data.active = false
        }
      }
      case "tandembased" : ctx.dancers.forEach {
        //   Dancer must either be in a tandem ..
        if (!ctx.isInTandem($0)) {
          //  .. or two nearby dancers must form a tandeom
          let others = ctx.dancersInOrder($0) { d2 in ctx.isInTandem(d2) }
          if (!others[0].isInFrontOf(others[1]) && !others[1].isInFrontOf(others[0])) {
            $0.data.active = false
          }
        }
      }
      case "wavebased", "" : 
        if (points.count > 0) {
          points.forEach { it in
            let others = ctx.dancersInOrder(it)
            if (!(others[0].isLeftOf(others[1]) || others[0].isRightOf(others[1])) ||
              !(others[1].isLeftOf(others[0]) || others[1].isRightOf(others[0]))) {
              it.data.active = false
            }
          }
        } else {
          //  No points, maybe a sausage
          let sausage = CallContext(TamUtils.getFormation("Sausage RH"))
          if (ctx.matchFormations(sausage,rotate: 180) != nil) {
            ctx.center(2).forEach { d in d.data.active = false }
          }
        }
      default : break
    }
    if (ctx.actives.count != 6) {
      throw CallError("Unable to find dancers to circulate")
    }
    //  Should be able to split the square to 2 3-dancer triangles
    var partitioned:[Dancer] = ctx.actives
    var p = 0
    if (ctx.actives.none { $0.location.x.isApprox(0.0) } ) {
      p = partitioned.partition { $0.location.x < 0 }
    } else if (ctx.actives.none { $0.location.y.isApprox(0.0) } ) {
      p = partitioned.partition { $0.location.y < 0 }
    } else {
      throw CallError("Unable to find Triangles")
    }
    if (p != 3) {
      throw CallError("Unable to find Triangles")
    }
    //  Figure out the circulates for each triangle
    let triangles = [partitioned[..<p],partitioned[p...]]
    try triangles.forEach { triangle in
      try triangle.forEach { d in
        let d2 =
        //  Scan ever-widening angles for other dancer
        //  of this triangle to circulate to
        triangle.first { d2 in d2.isInFrontOf(d) } ??
          triangle.first { d2 in d2 != d
            && d.angleToDancer(d2).abs < .pi / 2.0
            && !d.angleToDancer(d2).abs.isAround(.pi / 2) } ??
            triangle.first { d2 in d2 != d
              && d.angleToDancer(d2).abs.isAround(.pi / 2) } ??
              triangle.first { d2 in d2 != d
                && !d.angleToDancer(d2).abs.isAround(.pi) }
        if (d2 != nil) {
          d.path += oneCirculatePath(d,d2!)
        } else {
          throw CallError("Unable to calculate circulate path for $d")
        }
      }
    }


  }

}
