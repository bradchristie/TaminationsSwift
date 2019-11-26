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

class CallContext {

  //  XML files that have been loaded
  static var loadedXML = Dictionary<String, XMLDocument>()

  //  Index into files for specific calls
  //  Supplements looking up calls in TamUtils.calldata
  //  Keys are normalized call name
  //  Values are file names
  static var callindex = [String:[String]]()

  //  Initialize callindex with calls in theses files
  class func loadInitFiles() {

    let callindexinitfiles = [
      "b1/circle",
      "a1/clover_and_anything",
      "a1/cross_clover_and_anything",
      "c1/cross_your_neighbor",
      "c2/criss_cross_your_neighbor",
      "plus/explode_the_wave",
      "b1/sashay",
      "b1/ladies_chain",
      "a1/any_hand_concept",
      "a1/split_square_thru",
      "b2/sweep_a_quarter",
      "b1/circulate",
      "b1/face",
      "c1/butterfly_formation",
      "a2/all_4_all_8",
      "a1/as_couples",
      "b1/veer",
      "b1/circle",
      "b1/grand_square",
      "b1/lead_right",
      "b2/first_couple_go",
      "a1/as_couples",
      "c1/stretch_concept",
      "c1/butterfly_formation",
      "c1/o_formation",
      "c1/box_split_recycle",
      "c1/magic_column_formation",
      "c1/phantom_formation",
      "c1/tandem_concept",
      "c1/track_n",
      "c1/triple_box_concept",
      "b2/ocean_wave",
      "c1/wheel_and_anything",
      "plus/chase_right",
      "a1/fractional_tops",
      "a1/quarter_thru",
      "a1/three_quarter_thru",
      "b1/split_the_outside_couple",
      "a2/transfer_and_anything",
      "ms/eight_chain_thru"
    ]

    if (callindex.isEmpty) {
      callindexinitfiles.forEach {
        loadOneFile($0)
      }
    }

  }


  private class func loadOneFile(_ link:String) {
    if (loadedXML[link] == nil) {
      let doc = TamUtils.getXMLAsset(link)
      //  Add all the calls to the index
      doc.xpath("/tamination/tam").filter 
      { tam in tam.attr("sequencer") != "no" }.forEach { tam in 
        if let xref = tam.attr("xref-link") {
          loadOneFile(xref)
        } else {
          let norm = TamUtils.normalizeCall(tam.attr("title")!)
          if (callindex[norm] == nil) {
            callindex[norm] = [String]()
          }
          callindex[norm]!.append(link)
        }
      }
      loadedXML[link] = doc
    }
  }


  //  Load all XML files that might be used to interpret a call
  class func loadCalls(_ calltext: [String]) {
    calltext.forEach { line in
      line.minced().forEach { name in
        //  Load any animation files that match
        let norm = TamUtils.normalizeCall(name)
        let callitems = TamUtils.callmap[norm] ?? []
        let callfiles = callitems.map { $0.link }
        callfiles.forEach {
          loadOneFile($0)
        }
        //  Check for coded calls that require xml files
        CodedCall.getCodedCall(name)?.requires.forEach {
          loadOneFile($0)
        }
      }
    }
  }


  var callname = ""
  var level = LevelObject.find("b1")
  var callstack: [Call] = []
  var dancers: [Dancer] = []
  private var source: CallContext? = nil
  private var snap = true
  private var extend = true

  //  For cases where creating a new context from a source,
  //  get the dancers from the source and clone them.
  //  The new context contains the dancers in their current location
  //  and no paths.
  //  Create a context from an array of Dancer
  init(_ sourcedancers: [Dancer], beat: Double) {
    dancers = sourcedancers.map { it in
      it.animate(beat:beat)
      let d = Dancer(it)
      it.animateToEnd()
      return d
    }
  }

  convenience init(_ sourcedancers: [Dancer]) {
    self.init(sourcedancers, beat:Double.greatestFiniteMagnitude)
  }

  convenience init(_ source: CallContext,
                   _ sourcedancers: [Dancer] = [],
                   beat: Double = Double.greatestFiniteMagnitude) {
    self.init(sourcedancers.count > 0 ? sourcedancers : source.dancers, beat:beat)
    self.source = source
    snap = source.snap
  }

  //  Create a context from a formation defined in XML
  //  The element passed in can be either a "tam" from
  //  an animation, or a formation
  convenience init(_ tam: XMLElement) {
    let numberArray = TamUtils.getNumbers(tam)
    let coupleArray = TamUtils.getCouples(tam)
    let f = (tam.attr("formation") != nil)
      ? TamUtils.getFormation(tam.attr("formation")!)
      : tam.children(tag: "formation").first ?? tam
    var dlist: [Dancer] = []
    for (i, element) in f.children(tag: "dancer").enumerated() {
      //  Make sure each dancer in the list is immediately followed by its
      //  diagonal opposite.  Required for mapping.
      let d1 = Dancer(number: numberArray[i * 2], couple: coupleArray[i * 2],
        gender: element.attr("gender")! == "boy" ? 1 : 2,
        fillcolor: UIColor.white, // color not important, these are never displayed
        mat: Matrix(x: element.attr("x")!.d, y: element.attr("y")!.d)
          * Matrix(angle: element.attr("angle")!.d.toRadians),
        geom: GeometryMaker.makeAll(.SQUARE).first!, moves: [])
      dlist.append(d1)
      let d2 = Dancer(number: numberArray[i * 2 + 1], couple: coupleArray[i * 2 + 1],
        gender: element.attr("gender")! == "boy" ? 1 : 2,
        fillcolor: UIColor.white, // color not important, these are never displayed
        mat: Matrix(x: element.attr("x")!.d, y: element.attr("y")!.d)
          * Matrix(angle: element.attr("angle")!.d.toRadians),
        geom: GeometryMaker.makeAll(.SQUARE).second!, moves: [])
      dlist.append(d2)
    }
    self.init(dlist)
  }

  func noSnap() -> CallContext {
    snap = false
    return self
  }

  func noExtend() -> CallContext {
    extend = false
    return self
  }

  //  Get the active dancers, e.g. for "Boys Trade" the boys are active
  var actives: [Dancer] {
    dancers.filter {
      $0.data.active
    }
  }

  /**
   * Append the result of processing this CallContext to it source.
   * The CallContext must have been previously cloned from the source.
   */
  func appendToSource() {
    dancers.forEach { it in
      it.clonedFrom!.path.add(it.path)
      it.clonedFrom!.animateToEnd()
    }
    if let mysource = source {
      if (mysource.level < level) {
        mysource.level = level
      }
    }
  }

  private func applyCall(_ calltext: String) throws {
    try interpretCall(calltext)
    try performCall()
    appendToSource()
  }

  private func checkForAction(_ calltext: String) throws {
    if (callstack.none { c in
      c is Action || c is XMLCall
    }) {
      throw CallError("\(calltext) does nothing")
    }
  }

  @discardableResult
  func applyCalls(_ calltext: [String]) throws -> CallContext {
    try calltext.dropLast().forEach {
      try CallContext(self).applyCall($0)
    }
    let ctx = CallContext(self)
    ctx.extend = extend
    try ctx.applyCall(calltext.last!)
    return self
  }
  @discardableResult
  func applyCalls(_ calltext: String...) throws -> CallContext {
    try applyCalls(calltext)
  }

  /**
   * This is the main loop for interpreting a call
   * @param calltxt  One complete call, lower case, words separated by single spaces
   */
  func interpretCall(_ calltxt: String) throws {
    var calltext = calltxt.replaceAll("\\s+", " ")
    var err: CallError = CallNotFoundError(calltxt)
    //  Clear out any previous paths from incomplete parsing
    dancers.forEach {
      $0.path = Path()
    }
    callname = ""
    //  If a partial interpretation is found (like 'boys' of 'boys run')
    //  it gets popped off the front and this loop interprets the rest
    while (!calltext.isEmpty) {
      //  Try chopping off each word from the end of the call until
      //  we find something we know
      if try (!calltext.chopped().any { onecall in
        var success = false

        //  First try to find an exact match in Taminations
        do {
          try success = self.matchXMLcall(onecall)
        } catch let err2 as CallError {
          err = err2
        } catch {
        }

        //  Then look for a code match
        do {
          try success = success || self.matchCodedCall(onecall)
        } catch let err3 as CallError {
          err = err3
        } catch {
        }
        //  Finally try a fuzzier match in Taminations
        do {
          try success = success || self.matchXMLcall(onecall, fuzzy: true)
        } catch let err4 as CallError {
          err = err4
        }

        if (success) {
          //  Remove the words we matched, break out of
          //  the chopped loop, and continue if any words left
          calltext = calltext.replaceFirst(onecall, "").trim()
        }


        return success
      }) {
        //  Every combination from callwords.chopped failed
        throw err
      }
    }
    try checkForAction(calltxt)
  }


  //  Main routine to map a call to an animation in a Taminations XML file
  private func matchXMLcall(_ calltext: String, fuzzy: Bool = false) throws -> Bool {
    let ctx0 = self
    var ctx1 = self
    //  If there are precursors, run them first so the result
    //  will be used to match formations
    //  Needed for calls like "Explode And ..."
    if (!callstack.isEmpty) {
      ctx1 = CallContext(self)
      ctx1.callstack = callstack
      //  Ignore any errors, some precursors (like Half) expect to find more on the stack
      do {
        try ctx1.performCall()
      } catch _ as CallError {

      }
    }
    //  If actives != dancers, create another call context with just the actives
    let dc = ctx1.dancers.count
    let ac = ctx1.actives.count
    var perimeter = false
    if (dc != ac) {
      //  Don't try to match unless the actives are together
      if (ctx1.actives.any { d in
        ctx1.inBetween(d, ctx1.actives.first!).any {
          !$0.data.active
        }
      }) {
        perimeter = true
      }
      ctx1 = CallContext(ctx1, ctx1.actives)
    }
    //  Try to find a match in the xml animations
    let callnorm = TamUtils.normalizeCall(calltext)
    let callitems = TamUtils.callmap[callnorm] ?? []
    let callfiles1 = callitems.map {
      $0.link
    }
    let callfiles2 = CallContext.callindex[callnorm] ?? []
    let callfiles = callfiles1 + callfiles2
    //  Found xml file with call, now look through each animation
    let found = callfiles.isEmpty
    var bestOffset = Double.greatestFiniteMagnitude
    var xmlCall: XMLCall? = nil
    var title = ""
    let matches = callfiles.any { it in
      CallContext.loadedXML[it]?.xpath("/tamination/tam").filter { tam in
        tam.attr("sequencer") != "no" &&
          TamUtils.normalizeCall(tam.attr("title")!) == callnorm &&
          //  Check for calls that must go around the centers
          (!perimeter || (tam.attr("sequencer") ?? "").contains("perimeter"))
      }.forEach { tam in
        //  Calls that are gender-specific, e.g. Star Thru,
        //  are specifically flagged in the XML
        let sexy = tam.attr("sequencer")?.contains("gender-specific") ?? false
        //  Make sure we don't mismatch heads and sides
        //  on calls that specifically refer to them
        let headsmatchsides = !tam.attr("title")!.contains("Heads?|Sides?")
        //  Try to match the formation to the current dancer positions
        let ctx2 = CallContext(tam)
        let mmm = ctx1.matchFormations(ctx2, sexy: sexy, fuzzy: fuzzy, handholds: false,
          headsmatchsides: headsmatchsides)
        if let mm = mmm {
          let matchResult = ctx1.computeFormationOffsets(ctx2, mm)
          let totOffset = matchResult.offsets.reduce(0.0) {
            (s, v) in s + v.length
          }
          if (totOffset < bestOffset) {
            xmlCall = XMLCall(tam, mm, ctx2)
            bestOffset = totOffset
            title = tam.attr("title")!
          }
        }
      }
      if (xmlCall != nil) {
        if (["Allemande Left",
             "Dixie Grand",
             "Right and Left Grand"].contains(xmlCall!.name)) {
          if (!checkResolution(xmlCall!.ctx2, xmlCall!.xmlmap)) {
            Application.app.sendMessage(.RESOLUTION_ERROR)
          }
        }
        // add XMLCall object to the call stack
        ctx0.callstack.append(xmlCall!)
        ctx0.callname = callname + title.replaceAll("\\(.*\\)", "") + " "
        // set level to max of this and any previous
        let thislevel = LevelObject.find(it)
        if (thislevel > ctx0.level) {
          ctx0.level = thislevel
        }
        return true
      }
      return false

    }
    if (found && !matches) {
      //  Found the call but formations did not match
      throw FormationNotFoundError(calltext)
    }
    return matches
  }

  //  For calls that should only be used when the square is resolved,
  //  check that the dancers are in the correct order.
  //  This is only used for XML calls, coded calls check in their code.
  //  Since the XML dancers are resolved, the user's dancers must map
  //  to them in order plus or minus a rotation.
  //  So the mapping of the couples numbering mod 4 must be the same.
  private func checkResolution(_ ctx2:CallContext, _ mapping:[Int]) -> Bool {
    dancers.mapIndexed { (i,d) in
      (d.number_couple.d - ctx2.dancers[mapping[i]].number_couple.d + 4).truncatingRemainder(dividingBy: 4)
    }.distinct().count == 1
  }

  //  Once a mapping of two formations is found,
  //  this computes the difference between the two.
  struct FormationMatchResult {
    var transform:Matrix
    var offsets:[Vector]
  }

  func computeFormationOffsets(_ ctx2:CallContext, _ mapping:[Int]) -> FormationMatchResult {
    var dvbest:[Vector] = []
    //  We don't know how the XML formation needs to be turned to overlap
    //  the current formation.  So do an RMS fit to find the best match.
    var bxa:Array<Array<Double>> = [[0,0],[0,0]]
    actives.enumerated().forEach { (i,d1) in
      let v1 = d1.location
      let v2 = ctx2.dancers[mapping[i]].location
      bxa[0][0] += v1.x * v2.x
      bxa[0][1] += v1.y * v2.x
      bxa[1][0] += v1.x * v2.y
      bxa[1][1] += v1.y * v2.y
    }
    let (u,_,v) = Matrix(bxa[0][0], bxa[1][0], 0.0, bxa[0][1], bxa[1][1], 0.0).svd22()
    let ut = u.transpose()
    let rotmat = (v * ut).snapTo90()
    //  Now rotate the formation and compute any remaining
    //  differences in position
    actives.enumerated().forEach { (j,d2) in
      let v1 = d2.location
      let v2 = rotmat * ctx2.dancers[mapping[j]].location
      dvbest += [v1 - v2]
    }
    return FormationMatchResult(transform: rotmat, offsets: dvbest)
  }

  /*
  * Algorithm to match formations
  * Match dancers relative to each other, rather than compare absolute positions
  * Returns integer values for axis and quadrant directions
  *           0
  *         7 | 1
  *       6 --+-- 2
  *         5 | 3
  *           4
  * 2 cases
  *   1.  Dancers facing same or opposite directions
  *       - If dancers are lined up 0, 90, 180, 270 angles must match
  *       - Other angles match by quadrant
  *   2.  Dancers facing other relative directions (commonly 90 degrees)
  *       - Dancers must match quadrant or adj boundary
  *
  *
  *
  */

  private func angleBin(_ a:Double) -> Int {
    switch a {
      case let x where x.angleEquals(0) : return 0
      case let x where x.angleEquals(.pi / 2) : return 2
      case let x where x.angleEquals(.pi) : return 4
      case let x where x.angleEquals(-.pi / 2) : return 6
      case let x where x > 0 && x < .pi / 2 : return 1
      case let x where x > .pi / 2 && x < .pi : return 3
      case let x where x < 0 && x > -.pi / 2 : return 7
      case let x where x < -.pi / 2 && x > -.pi : return 5
      default : return -1
    }
  }
  private func dancerRelation(_ d1:Dancer, _ d2:Dancer) -> Int {
    angleBin(d1.angleToDancer(d2))
  }

  private func matchFormations(_ ctx2: CallContext,
                               sexy:Bool=false,
                               fuzzy:Bool=false,
                               rotate:Bool=false,
                               handholds: Bool=true,
                               headsmatchsides:Bool=true) -> [Int]? {
    if (dancers.count != ctx2.dancers.count) {
      return nil
    }
    //  Find mapping using DFS
    var mapping = [Int](repeating: -1, count: dancers.count)
    var bestmapping:[Int]? = nil
    var bestOffset:Double = 0.0
    var rotated = [Bool](repeating: false, count: dancers.count)
    var mapindex = 0
    while (mapindex >= 0 && mapindex < dancers.count) {
      var nextmapping = mapping[mapindex] + 1
      var found = false
      while (!found && nextmapping < ctx2.dancers.count) {
        //  Dancers in both contexts must be pairs of diagonal opposites
        //  Makes mapping much more efficient
        mapping[mapindex] = nextmapping
        mapping[mapindex + 1] = nextmapping ^ 1
        if (testMapping(self, ctx2, mapping: mapping, index: mapindex,
          sexy: sexy, fuzzy:fuzzy,
          handholds: handholds, headsmatchsides:headsmatchsides)) {
          found = true
        } else {
          nextmapping += 1
        }
      }
      if (nextmapping >= ctx2.dancers.count) {
        //  No more mappings for this dancer
        mapping[mapindex] = -1
        mapping[mapindex + 1] = -1
        //  If fuzzy, try rotating this dancer
        if (rotate && !rotated[mapindex]) {
          dancers[mapindex].rotateStartAngle(180.0)
          dancers[mapindex+1].rotateStartAngle(180.0)
          rotated[mapindex] = true
        } else {
          rotated[mapindex] = false
          mapindex -= 2
        }
      } else {
        //  Mapping found
        mapindex += 2
        if (mapindex >= dancers.count) {
          //  All dancers mapped
          //  Rate the mapping and save if best
          let matchResult = computeFormationOffsets(ctx2,mapping)
          //  Don't match if some dancers are too far from their mapped location
          let maxOffset = matchResult.offsets.max { v1,v2 in v1.length > v2.length }!
          if (maxOffset.length < 2.0) {
            let totOffset = matchResult.offsets.reduce(0.0, { $0 + $1.length })
            if (bestmapping == nil || totOffset < bestOffset) {
              bestmapping = mapping  // in Swift this copies the array
              bestOffset = totOffset
            }
          }
          // continue to look for more mappings
          mapindex -= 2
        }
      }
    }
    return bestmapping
  }

  func testMapping(_ ctx1: CallContext, _ ctx2:CallContext, mapping:[Int], index i:Int,
                   sexy:Bool = false,
                   fuzzy:Bool = false,
                   handholds:Bool = true,
                   headsmatchsides:Bool = true) -> Bool {
    if (sexy && (ctx1.dancers[i].gender != ctx2.dancers[mapping[i]].gender)) {
      return false
    }
    //  Special check for calls with "Heads" or "Sides"
    if (!headsmatchsides) {
      //  If dancers are in squared set, check that the dancers are in the same
      //  absolute location
      if (ctx1.isSquare()) {
        if (!ctx1.dancers[i].anglePosition.angleEquals(ctx2.dancers[mapping[i]].anglePosition)) {
          return false
        }
      } else {
        //  Dancers not in squared set, call refers to original heads or sides
        if (Int(ctx1.dancers[i].number_couple)! % 2 !=
          Int(ctx2.dancers[mapping[i]].number_couple)! % 2) {
          return false
        }
      }
    }
    return ctx1.dancers.enumerated().allSatisfy { (j,d1) in
      if (mapping[j] < 0 || i==j) {
        return true
      } else {
        let relq1 = self.dancerRelation(ctx1.dancers[i], ctx1.dancers[j])
        let relt1 = self.dancerRelation(ctx2.dancers[mapping[i]],ctx2.dancers[mapping[j]])
        let relq2 = self.dancerRelation(ctx1.dancers[j], ctx1.dancers[i])
        let relt2 = self.dancerRelation(ctx2.dancers[mapping[j]],ctx2.dancers[mapping[i]])
        //  If dancers are side-by-side, make sure handholding matches by checking distance
        if (handholds && (relq1 == 2 || relq1 == 6) && (relq2 == 2 || relq2 == 6)) {
          let d1 = ctx1.dancers[i].distanceTo(ctx1.dancers[j])
          let hold1 = d1 < 2.1 &&
            (ctx1.dancerToLeft(ctx1.dancers[i]) == ctx1.dancers[j] ||
              ctx1.dancerToRight(ctx1.dancers[i]) == ctx1.dancers[j] )
          let d2 = ctx2.dancers[mapping[i]].distanceTo(ctx2.dancers[mapping[j]])
          let hold2 = d2 < 2.1 &&
            (ctx2.dancerToLeft(ctx2.dancers[mapping[i]]) == ctx2.dancers[mapping[j]] ||
              ctx2.dancerToRight(ctx2.dancers[mapping[i]]) == ctx2.dancers[mapping[j]] )
          return relq1 == relt1 && relq2 == relt2 && hold1 == hold2
        }
        if (fuzzy) {
          let reldif1 = (relt1-relq1).abs
          let reldif2 = (relt2-relq2).abs
          return (reldif1==0 || reldif1==1 || reldif1==7) &&
            (reldif2==0 || reldif2==1 || reldif2==7)
        } else {
          return relq1==relt1 && relq2==relt2
        }
      }
    }
  }


  private func matchCodedCall(_ calltext: String) throws -> Bool {
    if let call = CodedCall.getCodedCall(calltext) {
      callstack.append(call)
      callname += call.name + " "
      return true
    } else {
      return false
    }
  }

  //  Perform calls by popping them off the stack until the stack is empty.
  //  This doesn't run an animation, rather it takes the stack of calls
  //  and builds the dancer movements.
  func performCall() throws {
    analyze()
    try callstack.enumerated().forEach { (i,c) in
      try c.performCall(self, i)
      if (c is Action && i < callstack.count-1) {
        analyze()
      }
      //  A few calls (e.g. Hinge) don't know their level until the call is performed
      if (c.level > level) {
        level = c.level
      }
    }
    callstack.enumerated().forEach { (i,c) in c.postProcess(self, i) }
    extendPaths()
  }

  //  See if the current dancer positions resemble a standard formation
  //  and, if so, snap to the standard
  private static let standardFormations = [
    "Normal Lines Compact",
    "Normal Lines",
    "Double Pass Thru",
    "Quarter Tag",
    "Tidal Line RH",
    "I-Beam",
    "Diamonds RH Girl Points",
    "Diamonds RH PTP Girl Points",
    "Hourglass RH BP",
    "Galaxy RH GP",
    "Butterfly RH",
    "O RH",
    "Sausage RH",
    "T-Bone URRD",
    "T-Bone RUUL",
    "T-Bone DLDL",
    "T-Bone RDRD",
    "T-Bone UURL",
    "T-Bone RLUU",
    //  There are also 8 possible 3x1 t-bones not listed here
    "Static Square"    
  ]
  private static let twoCoupleFormations = [
    "Facing Couples Compact",
    "Facing Couples",
    "Two-Faced Line RH",
    "Diamond RH",
    "Single Eight Chain Thru",
    "Single Quarter Tag",
    "Square RH",
    "Square LH"    
  ]


  struct BestMapping {
    var name:String
    var mapping:[Int]
    var offsets:[Vector]
    var totOffset:Double
  }
  func matchStandardFormation() {
    //  Make sure newly added animations are finished
    dancers.forEach { d in
      d.path.recalculate()
      d.animateToEnd()
    }
    //  Work on a copy with all dancers active, mapping only uses active dancers
    let ctx1 = CallContext(self)
    ctx1.dancers.forEach {
      $0.data.active = true
    }
    var bestMapping: BestMapping? = nil
    let formations = ctx1.dancers.count == 4
      ? CallContext.twoCoupleFormations : CallContext.standardFormations
    formations.forEach { f in
      let ctx2 = CallContext(TamUtils.getFormation(f))
      //  See if this formation matches
      let mappingq = ctx1.matchFormations(ctx2, sexy: false, fuzzy: true, rotate: true, handholds: false)
      if let mapping = mappingq {
        //  If it does, get the offsets
        let matchResult = ctx1.computeFormationOffsets(ctx2, mapping)
        //  If the match is at some odd angle (not a multiple of 90 degrees)
        //  then consider it bogus
        let angsnap = matchResult.transform.angle / (.pi / 4)
        if (angsnap.isApproxInt()) {
          let totOffset = matchResult.offsets.reduce(0.0) { s, v in
            s + v.length
          }
          //  Favor formations closer to the top of the list
          if (bestMapping == nil || totOffset + 0.2 < bestMapping!.totOffset) {
            bestMapping = BestMapping(
              name: f, // only used for debugging
              mapping: mapping,
              offsets: matchResult.offsets,
              totOffset: totOffset
            )
          }
        }
      }
    }
    if let bestMap = bestMapping {
      for (i, d) in dancers.enumerated() {
        if (bestMap.offsets[i].length > 0.1) {
          //  Get the last movement
          let m = d.path.movelist.count > 0
            ? d.path.movelist.removeLast()
            : TamUtils.getMove("Stand").notFromCall().pop()
          //  Transform the offset to the dancer's angle
          d.animateToEnd()
          let vd = bestMapping!.offsets[i].rotate(-d.tx.angle)
          //  Apply it
          d.path.add(m.skew(-vd.x, -vd.y))
          d.animateToEnd()
        }
      }
    }
  }

  //  Return max number of beats among all the dancers
  var maxBeats: Double {
    dancers.reduce(0, { max($0, $1.path.beats) })
  }

  //  Return all dancers, ordered by distance, that satisfies a conditional
  func dancersInOrder(_ d: Dancer, _ f: (Dancer) -> Bool = { _ in return true }) -> [Dancer] {
    dancers.filter {
      $0 != d
    }.filter(f).sorted {
      $0.distanceTo(d) < $1.distanceTo(d)
    }
  }

  //  Return closest dancer that satisfies a given conditional
  func dancerClosest(_ d: Dancer, _ f: (Dancer) -> Bool) -> Dancer? {
    dancersInOrder(d, f).first
  }

  //  Return dancer directly in front of given dancer
  func dancerInFront(_ d: Dancer) -> Dancer? {
    dancerClosest(d) { d2 in
      d2.isInFrontOf(d)
    }
  }

  //  Return dancer directly in back of given dancer
  func dancerInBack(_ d: Dancer) -> Dancer? {
    dancerClosest(d) { d2 in
      d2.isInBackOf(d)
    }
  }

  //  Return dancer directly to the right of given dancer
  func dancerToRight(_ d: Dancer) -> Dancer? {
    dancerClosest(d) { d2 in
      d2.isRightOf(d)
    }
  }

  //  Return dancer directly to the left of given dancer
  func dancerToLeft(_ d: Dancer) -> Dancer? {
    dancerClosest(d) { d2 in
      d2.isLeftOf(d)
    }
  }

  //  Return dancer that is facing the front of this dancer
  func dancerFacing(_ d: Dancer) -> Dancer? {
    let d2 = dancerInFront(d)
    return (d2 != nil && dancerInFront(d2!) == d) ? d2 : nil
  }

  //  Return dancers that are in between two other dancers
  func inBetween(_ d1: Dancer, _ d2: Dancer) -> [Dancer] {
    dancers.filter { it in
      it != d1 && it != d2 &&
        (it.distanceTo(d1) + it.distanceTo(d2)).isApprox(d1.distanceTo(d2))
    }
  }

  //  Return all the dancers to the right, in order
  func dancersToRight(_ d: Dancer) -> [Dancer] {
    dancersInOrder(d) { d2 in
      d2.isRightOf(d)
    }
  }

  //  Return all the dancers to the left, in order
  func dancersToLeft(_ d: Dancer) -> [Dancer] {
    dancersInOrder(d) { d2 in
      d2.isLeftOf(d)
    }
  }

  //  Return all the dancers in front, in order
  func dancersInFront(_ d: Dancer) -> [Dancer] {
    dancersInOrder(d) { d2 in
      d2.isInFrontOf(d)
    }
  }

  //  Return all the dancers in back, in order
  func dancersInBack(_ d: Dancer) -> [Dancer] {
    dancersInOrder(d) { d2 in
      d2.isInBackOf(d)
    }
  }

  //  Return outer 2, 4 , 6 dancers
  func outer(_ num: Int) -> [Dancer] {
    Array(dancers.sorted {
      d1, d2 in
      d1.location.length < d2.location.length
    }.dropFirst(dancers.count - num))
  }

  //  Return center 2, 4 , 6 dancers
  func center(_ num: Int) -> [Dancer] {
    Array(dancers.sorted {
      d1, d2 in
      d1.location.length < d2.location.length
    }.dropLast(dancers.count - num))
  }

  //  Returns points of a diamond formations
  //  Formation to match must have girl points
  private func tryOneDiamondFormation(_ f:String) -> [Dancer] {
    let ctx2 = CallContext(TamUtils.getFormation(f))
    var points:[Dancer] = []
    if let mapping = matchFormations(ctx2,rotate:true) {
      for (i,d) in dancers.enumerated() {
        if (ctx2.dancers[mapping[i]].gender == Gender.GIRL) {
          points.append(d)
        }
      }
    }
    return points
  }
  func points() -> [Dancer] {
    tryOneDiamondFormation("Diamond LH Boys Center") +
      tryOneDiamondFormation("Diamonds RH Girl Points") +
      tryOneDiamondFormation("Diamonds RH PTP Girl Points") +
      tryOneDiamondFormation("Hourglass RH GP") +
      tryOneDiamondFormation("Galaxy RH GP")
  }


  //  Return true if this dancer is in a wave or mini-wave
  func isInWave(_ d: Dancer, _ d1: Dancer? = nil) -> Bool {
    if let d2 = d1 ?? d.data.partner {
      return d.angleToDancer(d2).angleEquals(d2.angleToDancer(d))
    }
    return false
  }

  func isFacingSameDirection(_ d:Dancer, _ d2:Dancer) -> Bool {
    return d.angleFacing.isAround(d2.angleFacing)
  }

  //  Return true if this dancer is part of a couple facing same direction
  func isInCouple(_ d: Dancer, _ d1: Dancer? = nil) -> Bool {
    if let d2 = d1 ?? d.data.partner {
      return d.angleFacing.angleEquals(d2.angleFacing)
    }
    return false
  }

  //  Return true if this dancer is in tandem with another dancer
  func isInTandem(_ d: Dancer) -> Bool {
    return
      d.data.trailer ? dancerInFront(d)!.data.leader
        : d.data.leader ? dancerInBack(d)!.data.trailer
        : false
  }

  //  Return true if this is 4 dancers in a line
  func isLine() -> Bool {
    return
      //  Must have 4 dancers
      dancers.count == 4 &&
        //  Each dancer must have right or left shoulder to origin
        dancers.all { d in
          d.angleToOrigin.abs.isApprox(.pi / 2)
        } &&
        //  All dancers must either be on the y axis
        (dancers.all { d in
          d.location.x.isApprox(0.0)
        } ||
          //  or on the x axis
          dancers.all { d in
            d.location.y.isApprox(0.0)
          })
  }

  //  Return true if 8 dancers are in 2 general lines of 4 dancers each
  func isLines() -> Bool {
    return dancers.all {
      d in dancersToRight(d).count + dancersToLeft(d).count == 3
    }
  }

  //  Return true if 8 dancers are in 2 general columns of 4 dancers each
  func isColumns() -> Bool {
    return dancers.all {
      d in dancersInFront(d).count + dancersInBack(d).count == 3
    }
  }

  //  Return true if 8 dancers are in two-faced lines
  func isTwoFacedLines() -> Bool {
    return isLines() &&
      dancers.all { d in isInCouple(d) } &&
      dancers.filter { d in d.data.leader }.count == 4 &&
      dancers.filter { d in d.data.leader }.count == 4
  }

  //  Return true if dancers are at squared set positions
  func isSquare() -> Bool {
    return dancers.all { d in
      let loc = d.location
      return (loc.x.abs.isApprox(3.0) && loc.y.abs.isApprox(1.0)) ||
        (loc.x.abs.isApprox(1.0) && loc.y.abs.isApprox(3.0))
    }
  }

  //  Return true if dancers are tidal line or wave
  func isTidal() -> Bool {
    return dancersToRight(dancers.first!).count + dancersToLeft(dancers.first!).count == 7
  }

  //  Return true if dancers are in any type of 2x4 formation
  func isTBone() -> Bool {
    let centerCount = dancers.filter { d in
      let loc = d.location
      return loc.x.abs.isApprox(1.0) && loc.y.abs.isApprox(1.0)
    }.count
    let xCount = dancers.filter { d in
      let loc = d.location
      return loc.x.abs.isApprox(3.0) && loc.y.abs.isApprox(1.0)
    }.count
    let yCount = dancers.filter { d in
      let loc = d.location
      return loc.x.abs.isApprox(1.0) && loc.y.abs.isApprox(3.0)
    }.count
    return centerCount == 4 &&
      ((xCount == 4 && yCount == 0) || (xCount == 0 && yCount == 4))
  }

  func isCollision() -> Bool {
    dancers.any { d in
      dancers.any { d2 in
        d != d2 &&
          d.location.x.isApprox(d2.location.x) &&
          d.location.y.isApprox(d2.location.y)
      }
    }
  }

  //  Get direction dancer would roll
  class Rolling {
    let direction:Double
    init(_ d:Double) {
      direction = d
    }
    var isLeft:Bool { get { return direction > 0.1 } }
    var isRight:Bool { get { return direction < -0.1 } }
  }
  func roll(_ d:Dancer) -> Rolling {
    //  Look at the last curve of the past, excluding post-processing adjustments
    return Rolling(d.path.movelist.filter({ move in move.fromCall }).lastOrNull()?.brotate.rolling() ?? 0.0)
  }

  //  Level off the number of beats for each dancer
  func extendPaths() {
    //  Remove anything previously added
    contractPaths()
    //  get the longest number of beats
    let maxb = maxBeats
    //  add that number as needed by using the "Stand" move
    dancers.forEach { d in
      d.data.actionBeats = d.path.beats
      let b = maxb - d.path.beats
      if (b > 0) {
        d.path.add(TamUtils.getMove("Stand").changebeats(b).notFromCall())
      }
    }
  }

  //  Strip off extra beats added by extendPaths
  func contractPaths() {
    dancers.forEach { d in
      while (d.path.movelist.lastOrNull()?.fromCall == false) {
        d.path.pop()
      }
    }
  }

  func analyze() {
    dancers.forEach { d in
      d.animateToEnd()
      d.data.beau = false
      d.data.belle = false
      d.data.leader = false
      d.data.trailer = false
      d.data.partner = nil
      d.data.center = false
      d.data.end = false
      d.data.verycenter = false
    }
    var istidal = false
    dancers.forEach { d1 in

      var bestleft:Dancer? = nil
      var bestright:Dancer? = nil
      var leftcount = 0
      var rightcount = 0
      var frontcount = 0
      var backcount = 0

      //  Count dancers to the left and right,
      //  and find the closest on each side
      dancers.filter { $0 != d1 }.forEach { d2 in
        if (d2.isRightOf(d1)) {
          rightcount += 1
          if (bestright == nil || d1.distanceTo(d2) < d1.distanceTo(bestright!)) {
            bestright = d2
          }
        } else if (d2.isLeftOf(d1)) {
          leftcount += 1
          if (bestleft == nil || d1.distanceTo(d2) < d1.distanceTo(bestleft!)) {
            bestleft = d2
          }
        }
        //  Also count dancers in front and in back
        else if (d2.isInFrontOf(d1)) {
          frontcount += 1
        }
        else if (d2.isInBackOf(d1)) {
          backcount += 1
        }
      }

      //  Use the results of the counts to assign belle/beau/leader/trailer
      //  and partner
      if (leftcount % 2 == 1 && rightcount % 2 == 0 && d1.distanceTo(bestleft!) < 3) {
        d1.data.partner = bestleft
        d1.data.belle = true
      }
      else if (rightcount % 2 == 1 && leftcount % 2 == 0 && d1.distanceTo(bestright!) < 3) {
        d1.data.partner = bestright
        d1.data.beau = true
      }
      if (frontcount % 2 == 0 && backcount % 2 == 1) {
        d1.data.leader = true
      }
      else if (frontcount % 2 == 1 && backcount % 2 == 0) {
        d1.data.trailer = true
      }
      //  Assign ends
      if (rightcount == 0 && leftcount > 1) {
        d1.data.end = true
      }
      else if (leftcount == 0 && rightcount > 1) {
        d1.data.end = true
      }
      else if (frontcount == 3 && backcount == 0) {
        d1.data.end = true
      }
      else if (backcount == 3 && frontcount == 0) {
        d1.data.end = true
      }
      //  The very centers of a tidal wave are ends
      //  Remember this special case for assigning centers later
      if (rightcount == 3 && leftcount == 4 || rightcount == 4 && leftcount == 3) {
        d1.data.end = true
        istidal = true
      }
    }
    //  Analyze for centers and very centers
    //  Sort dancers by distance from center
    let dorder = dancers.sorted { $0.location.length < $1.location.length }
    //  The 2 dancers closest to the center
    //  are centers (4 dancers) or very centers (8 dancers)
    if (!dorder[1].location.length.isApprox(dorder[2].location.length)) {
      if (dancers.count == 4) {
        dorder[0].data.center = true
        dorder[1].data.center = true
      } else {
        dorder[0].data.verycenter = true
        dorder[1].data.verycenter = true
      }
    }
    // If tidal, then the next 4 dancers are centers
    if (istidal) {
      [2,3,4,5].forEach { dorder[$0].data.center = true }
    }
    //  Otherwise, if there are 4 dancers closer to the center than the other 4,
    //  they are the centers
    else if (dancers.count > 4 &&
      !dorder[3].location.length.isApprox(dorder[4].location.length)) {
      [0,1,2,3].forEach { dorder[$0].data.center = true }
    }
  }


}
