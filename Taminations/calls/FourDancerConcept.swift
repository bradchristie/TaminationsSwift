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


//  This is a base class for concept calls that group or select
//  dancers in a way that they perform a 4-dancer call.
//  The concept maps the 4-dancer call to the real dancers.
//  Primary examples are As Couples Concept and Tandem Concept
class FourDancerConcept : Action {

  var conceptName:String { get { "" } }
  private var extraCall:String? { get {
    name.lowercased().contains("individually")
      ? name.replaceFirstIgnoreCase(".*individually ", "")
      : nil
  } }
  var realCall:String { get {
    name.replaceIgnoreCase("\(conceptName) ", "")
        .replaceIgnoreCase("individually.*", "")
  } }

  //  Return list of groups of dancers
  //  List must have 4 sub-lists
  //  Each sub-list has 2 or more real (or phantom) dancers
  //  For example, the groups for As Couples are the 4 couples
  func dancerGroups(_ ctx:CallContext) throws -> [[Dancer]]  { [[]] }

  //  Return start position of concept dancer for one group
  func startPosition(_ group:[Dancer]) -> Vector { Vector() }

  //  Compute location for a real dancer at a specific beat
  //  given location of the concept dancer
  func computeLocation(_ d:Dancer, _ m:Movement, _ mi:Int,
                       _ beat:Double, _ groupIndex:Int) -> Vector {
    Vector()
  }

  //  Any analysis or processing after call is applied to concept dancers
  //  but before application to real dancers
  func analyzeConceptResult(_ conceptctx:CallContext, _ realctx:CallContext) { }

  //  Make any changes to the final result (optional)
  func postAdjustment(_ ctx:CallContext, _ cd:Dancer, _ group:[Dancer]) { }

  override func perform(_ ctx: CallContext, _ index: Int) throws {
    //  Get dancer groups
    let groups = try dancerGroups(ctx)
    //  Create a concept dancer for each group dancer
    let singles:[Dancer] = groups.map { group in
      //  Select the gender for the concept dancer
      var g = Gender.NONE
      if (group.all {
        $0.gender == Gender.BOY
      }) {
        g = Gender.BOY
      }
      if (group.all {
        $0.gender == Gender.GIRL
      }) {
        g = Gender.GIRL
      }
      //  Select the couple number for the concept dancer
      //  Needed for e.g. <concept> Heads Run
      var nc = "0"
      if (group.all {
        $0.number_couple.matches("[13]{2}")
      }) {
        nc = "1"
      }
      if (group.all {
        $0.number_couple.matches("[24]{2}")
      }) {
        nc = "2"
      }
      //  Create the concept dancer
      let dsingle = Dancer(group.first!, number_couple: nc, gender: g.rawValue)
      //  Set the location for the concept dancer
      let newpos = startPosition(group)
      dsingle.setStartPosition(newpos)
      return dsingle
    }

    //  Create context for concept dancers
    let conceptctx = CallContext(singles)
    //  And apply the call
    try conceptctx.applyCalls(realCall)
    //  Hook for concept to see the result
    conceptctx.animate(0.0)
    analyzeConceptResult(conceptctx, ctx)

    //  Get the paths and apply to the original dancers
    conceptctx.dancers.enumerated().forEach { (ci,cd) in
      let group = groups[ci]
      //  Compute movement for each real dancer for each movement
      //  based on the concept dancer
      var cdbeat = 0.0
      cd.path.movelist.enumerated().forEach { (i,m) in
        group.enumerated().forEach { (gi,d) in
          conceptctx.animate(cdbeat)
          //  Get the 4 points needed to compute Bezier curve
          let p1 = (i==0) ? (d.location - cd.location).rotate(-cd.angleFacing)
                          : computeLocation(cd,m,i,0.0,gi)
          let p2 = computeLocation(cd,m,i,m.beats / 3.0,gi) - p1
          let p3 = computeLocation(cd,m,i,m.beats * 2.0 / 3.0,gi) - p1
          let p4 = computeLocation(cd,m,i,m.beats,gi) - p1
          //  Now we can compute the Bezier
          let cb = Bezier.fromPoints(Vector(), p2, p3, p4)
          //  And use it to build the Movement
          let cm = Movement(beats: m.beats,hands: m.hands,btranslate: cb, brotate: m.brotate)
          //  And add the Movement to the Path
          d.path.add(cm)
        }
        cdbeat += m.beats
      }
    }

    //  Let inherited classes make any adjustments
    ctx.animateToEnd()
    conceptctx.dancers.enumerated().forEach { (ci,cd) in
      postAdjustment(ctx,cd,groups[ci])
    }
    //  Perform any calls for single dancers (e.g. "individually roll")
    if let extra = extraCall {
      if (extra.trim().lowercased().matches("roll")) {
        try Roll("","").perform(ctx, 1)
      } else {
        throw CallError("Don't know how to Individually \(extra)")
      }
    }

  }
}
