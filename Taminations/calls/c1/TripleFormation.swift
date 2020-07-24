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

var isXaxis:Bool = false

extension Vector {
  var major:Double { isXaxis ? x : y }
  var minor:Double { isXaxis ? y : x }
}


class TripleFormation : Action {

  override var level: LevelData { LevelObject.find("c1") }

  static let tripleBoxFormations:Dictionary<String,Double> = [
      "Triple Boxes" : 1.0,
      "Triple Boxes 2" : 1.0,
      "Triple Lines" : 1.0,
      "Triple Columns" : 1.0
    ]

  func isXaxisFunc(_ ctx:CallContext) throws -> Bool { false }
  func majorValues(_ ctx:CallContext) -> [Double] { [] }
  func minorValues(_ ctx:CallContext) -> [Double] { [] }
  func tripleFormations(_ ctx:CallContext) -> [CallContext] { [] }

  override func perform(_ ctx: CallContext, _ i: Int) throws {
    isXaxis = try isXaxisFunc(ctx)
    let subcall = name.replaceFirstIgnoreCase("Triple (Box|Lines?|Waves?|Columns?) ", "")
    //  Add phantoms in spots not occupied by dancers
    var phantoms: [Dancer] = []
    majorValues(ctx).forEach { c1 in
      minorValues(ctx).forEach { c2 in
        let v = (isXaxis)
          ? Vector(c1, c2)
          : Vector(c2, c1)
        if (ctx.dancerAt(v) == nil) {
          let newPhantom = Dancer(
            ctx.dancers.first!,
            number: "P\(phantoms.count + 1)",
            gender: Gender.PHANTOM.rawValue
          )
          newPhantom.setStartPosition(v)
          phantoms.append(newPhantom)
        }
      }
    }
    //  Make the three boxes
    let tripleBoxCtx = CallContext(ctx, ctx.dancers + phantoms)
    let tripleContexts = tripleFormations(tripleBoxCtx)
    //  Apply call to each box
    try tripleContexts.forEach { box in
      if (box.dancers.count != 4) {
        throw CallError("Error splitting into groups - group has \(box.dancers.count) dancers.")
      }
      box.analyze()
      guard let rotbox = box.rotatePhantoms(subcall, rotate: 90, asym: true) else {
        throw CallError("Unable to do \(subcall) with these Triple Boxes")
      }
      try rotbox.applyCalls(subcall)
      //  If it ends in a bax, make it a compact box in major direction
      //  so it will fit with others to make a triple box
      if (rotbox.isBox() && rotbox.dancers.any {
        $0.location.major.abs.isGreaterThan(1.0)
      }) {
        rotbox.adjustToFormation("Facing Couples Close", rotate: 90)
      }
      //  Now apply the result to the 12-dancer triple box context
      rotbox.appendToSource()
      box.appendToSource()
    }
    tripleBoxCtx.animateToEnd()
    tripleBoxCtx.matchFormationList(TripleFormation.tripleBoxFormations)
    tripleBoxCtx.dancers.filter {
      $0.gender != Gender.PHANTOM
    }.forEach { bd in
      ctx.dancers.first {
        $0 == bd
      }!.path.add(bd.path)
    }
    ctx.noSnap()
  }

}


//  This class is for Triple Box only,
//  which is 12 spots arranged in a 2 x 6
class TripleBoxConcept : TripleFormation {

  override func majorValues(_ ctx:CallContext) -> [Double]
      { [ -5.0, -3.0, -1.0, 1.0, 3.0, 5.0] }
  override func minorValues(_ ctx:CallContext) -> [Double]
  { [-ctx.dancers[0].location.minor,ctx.dancers[0].location.minor ] }

  override func tripleFormations(_ ctx: CallContext) -> [CallContext] {
    [
      CallContext(ctx,
        ctx.dancers.filter {
          $0.location.major.isGreaterThan(1.0)
        }),
      CallContext(ctx,
        ctx.dancers.filter {
          $0.location.major.abs.isLessThan(3.0)
        }),
      CallContext(ctx,
        ctx.dancers.filter {
          $0.location.major.isLessThan(-1.0)
        })
    ]
  }

  override func isXaxisFunc(_ ctx: CallContext) -> Bool {
    let maxX = ctx.dancers.map { $0.location.x }.max()!
    let maxY = ctx.dancers.map { $0.location.y }.max()!
    return maxX > maxY
  }

}

class TripleLineConcept : TripleFormation {

  override func majorValues(_ ctx: CallContext)-> [Double] { [
    ctx.dancers.map { $0.location.major }.min()!,
    0.0,
    ctx.dancers.map { $0.location.major }.max()!
  ] }

  override func minorValues(_ ctx: CallContext) -> [Double]
    { [ -3.0,-1.0,1.0,3.0] }

  override func tripleFormations(_ ctx: CallContext) -> [CallContext] {
    let xVal = ctx.dancers.map { $0.location.major }.max()!
    return [
      CallContext(ctx,ctx.dancers.filter { $0.location.major.isAbout(-xVal) }),
      CallContext(ctx,ctx.dancers.filter { $0.location.major.isAbout(0.0) }),
      CallContext(ctx,ctx.dancers.filter { $0.location.major.isAbout(xVal) })
    ]
  }

  override func isXaxisFunc(_ ctx: CallContext) throws -> Bool {
    //  Triple line/wave/column - will have 4 different
    //  dancer coordinates only in axis parallel to lines
    //  Be careful about coords at 2.5, which are used often
    //  and could round up or down.
    let xGroups = ctx.dancers.groupBy { d in (d.location.x + 0.1).rounded().i }
    let yGroups = ctx.dancers.groupBy { d in (d.location.y + 0.1).rounded().i }
    //  isXaxis is true if there are 3 lines at x == 0 and x +/- 2 or 3
    if (xGroups.count == 4 && yGroups.count < 4) {
      return false
    } else if (xGroups.count < 4 && yGroups.count == 4) {
      return true
    }
    throw CallError("Unable to find Triple Lines/Waves/Columns")
  }


}