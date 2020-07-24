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

class PhantomConcept : Action {

  override var level: LevelData { LevelObject.find("c1") }
  let subcall:String

  override init(_ norm: String, _ name: String) {
    subcall = name.replaceIgnoreCase("Phantom ", "")
    super.init(norm, name)
  }

  private func addPhantoms(_ ctx:CallContext) throws -> CallContext {
    //  Add all the phantoms
    //  This assumes lines, will not work
    //  for phantom column formations
    let ang = ctx.dancers.first!.angleFacing
    let positions = (ang.isAround(0.0) || ang.isAround(.pi)) ?
      //  Lines are parallel to Y-axis
      //  Vectors must be pairs of diagonal opposites
      //  for XML mapping to work
      [Vector(2,-3),Vector(-2,3),Vector(2,-1),Vector(-2,1),
        Vector(-2,-3),Vector(2,3),Vector(-2,-1),Vector(2,1)]
    :
    //  Lines are parallel to X-axis
    [Vector(-3,2),Vector(3,-2),Vector(-1,2),Vector(1,-2),
    Vector(-3,-2),Vector(3,2),Vector(-1,-2),Vector(1,2)]

    //  Positions for phantoms are the ones not
    //  occupied by real dancers
    let phantomPositions = positions.filter { v in
      ctx.dancers.none { d in d.location.isApprox(v) }
    }
    //  Put phantoms in those positions
    let phantoms = phantomPositions.mapIndexed { i,v in
    Dancer(ctx.dancers.first!,
           number: "P\(i+1)",
          gender: Gender.PHANTOM.rawValue)
    .setStartPosition(v).rotateStartAngle((i.d.truncatingRemainder(dividingBy: 2.0)) * 180.0)
    }
    //  And merge with real dancers in a new context
    let phantomctx = CallContext(ctx,ctx.dancers+phantoms)
    //  Find good rotation
    phantomctx.analyze()
    guard let rotatectx = phantomctx.rotatePhantoms(subcall) else {
      throw CallError("Unable to find phantom formation for $subcall")
    }
    return rotatectx
  }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    let group1 = ctx.dancers.filter { d in
      d.angleFacing.isAround(0.0) || d.angleFacing.isAround(.pi)
    }
    let group2 = ctx.dancers.filter { d in !group1.contains(d) }
    try [group1,group2].forEach { group in
      //  Make a call context for this group
      let groupctx = CallContext(ctx,group)
      //  Add phantoms to make 8 dancers
      let phantomctx = try addPhantoms(groupctx)
      //  Perform 8-dancer call
      try phantomctx.applyCalls(subcall)
      //  Append the results
      let noph = phantomctx.dancers.filter { $0.gender != Gender.PHANTOM }
      zip(group,noph).forEach { d1, d2 in
        d1.path.add(d2.path)
      }
    }

  }
}
