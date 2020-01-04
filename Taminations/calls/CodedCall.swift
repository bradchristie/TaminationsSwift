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

class CodedCall : Call {

  //  "simple" calls are ones where we don't need the original text
  static let simpleCallMaker:Dictionary<String,()->CodedCall> = [
    "aceydeucey" : { AceyDeucey() },
    "and" : { And() },
    "and14more" : { QuarterMore() },
    "androll" : { Roll("androll","and Roll") },
    "roll" : { Roll("roll","Roll") },
    "backaway" : { BackAway() },
    "beau" : { Beaus() },
    "belle" : { Belles() },
    "boxcounterrotate" : { BoxCounterRotate() },
    "boxthegnat" : { BoxtheGnat() },
    "bracethru" : { BraceThru() },
    "boy" : { Boys() },
    "californiatwirl" : { CaliforniaTwirl() },
    "center" : { Centers() },
    "center6" : { CenterSix() },
    "cloverleaf" : { Cloverleaf() },
    "courtesyturn" : { CourtesyTurn() },
    "crossfold" : { CrossFold() },
    "crossovercirculate" : { CrossOverCirculate() },
    "crossrun" : { CrossRun() },
    "cross" : { Cross() },
    "doublestarthru" : { DoubleStarThru() },
    "end" : { Ends() },
    "facein" : { Face("facein","Face In") },
    "faceout" : { Face("faceout","Face Out") },
    "faceleft" : { Face("faceleft","Face Left") },
    "faceright" : { Face("faceright","Face Right") },
    "facing" : { FacingDancers() },
    "fold" : { Fold() },
    "girl" : { Girls() },
    "grandleftswingthru" : { GrandSwingThru("grandleftswingthru","Grand Left Swing Thru") },
    "grandswingthru" : { GrandSwingThru("grandswingthru","Grand Swing Thru") },
    "_grandswingleft" : { GrandSwingX("grandswingleft","Grand Swing Left") },
    "_grandswingright" : { GrandSwingX("grandswingright","Grand Swing Right") },
    "hinge" : { Hinge("hinge","Hinge") },
    "singlehinge" : { Hinge("hinge","Single Hinge") },
    "partnerhinge" : { Hinge("hinge","Partner Hinge") },
    "lefthinge" : { Hinge("lefthinge","Left Hinge") },
    "leftpartnerhinge" : { Hinge("lefthinge","Left Partner Hinge") },
    "ladies" : { Girls() },
    "12" : { Half() },
    "12sashay" : { HalfSashay() },
    "circulate" : { Circulate() },
    "all8circulate" : { Circulate() },
    "makemagic" : { MakeMagic() },
    "nothing" : { Nothing() },
    "partnertag" : { PartnerTag() },
    "passin" : { PassIn() },
    "passout" : { PassOut() },
    "passthru" : { PassThru("passthru","Pass Thru") },
    "leftpassthru" : { PassThru("leftpassthru","Left Pass Thru") },
    "point" : { Points() },
    "14in" : { QuarterIn("14in","Quarter In") },
    "14out" : { QuarterIn("14out","Quarter Out") },
    "14tag" : { QuarterTag() },
    "run" : { Run("run","Run") },
    "runright" : { Run("runright","Run Right") },
    "runleft" : { Run("runleft","Run Left") },
    "separate" : { Separate() },
    "slideleft" : { Slide("slideleft","Slide Left") },
    "slideright" : { Slide("slideright","Slide Right") },
    "slidein" : { Slide("slidein","Slide In") },
    "slideout" : { Slide("slideout","Slide Out") },
    "slidethru" : { SlideThru() },
    "slip" : { Slip() },
    "squeeze" : { Squeeze() },
    "starthru" : { StarThru("starthru","Star Thru") },
    "steptoacompactwave" : { StepToACompactWave("","") },
    "steptoacompactlefthandwave" : { StepToACompactWave("left","") },
    "leftstarthru" : { StarThru("leftstarthru","Left Star Thru") },
    "step" : { Step() },
    "switchtheline" : { SwitchTheLine() },
    "tagtheline" : { TagTheLine() },
    "32aceydeucey" : { ThreeByTwoAceyDeucey() },
    "34tag" : { ThreeQuartersTag() },
    "34tagtheline" : { ThreeQuartersTag() },
    "trade" : { Trade() },
    "partnertrade" : { Trade() },
    "touch14" : { TouchAQuarter("touch14","Touch a Quarter") },
    "lefttouch14" : { TouchAQuarter("lefttouch14","Left Touch a Quarter") },
    "triplestarthru" : { TripleStarThru() },
    "tripletrade" : { TripleTrade() },
    "turnback" : { TurnBack() },
    "zoom" : { Zoom() },
    "singlewheel" : { SingleWheel("singlewheel","Single Wheel") },
    "leftsinglewheel" : { SingleWheel("leftsinglewheel","Left Single Wheel") },
    "squaretheset" : { SquareTheSet() },
    "sweep14" : { SweepAQuarter() },
    "turnthru" : { TurnThru("turnthru","Turn Thru") },
    "leftturnthru" : { TurnThru("leftturnthru","Left Turn Thru") },
    "twice" : { Twice("twice","Twice") },
    "gotwice" : { Twice("twice","Go Twice") },
    "verycenter" : { VeryCenters() },
//  standard Walk and Dodge from waves, columns, etc
//  also Centers Walk and Dodge goes through here
    "walkanddodge" : { WalkandDodge("walkanddodge","Walk and Dodge") },
    "wheelaround" : { WheelAround("wheelaround","Wheel Around") },
    "withtheflow" : { WithTheFlow() },
    "reversewheelaround" : { WheelAround("reversewheelaround","Reverse Wheel Around") },
    "zig" : { Zig("zig","Zig") },
    "zag" : { Zig("zag","Zag") },
    "zigzig" : { ZigZag("zigzig","Zig Zig") },
    "zigzag" : { ZigZag("zigzag","Zig Zag") },
    "zagzig" : { ZigZag("zagzig","Zag Zig") },
    "zagzag" : { ZigZag("zagzag","Zag Zag") },
    "zing" : { Zing() }
  ]

  //  More complex calls where the text is needed either to select
  //  the correct variation or to echo the expected name
  static let complexCallMaker:Dictionary<String,(String,String)->CodedCall> = [
    "head" : { (norm:String,call:String) in HeadsSides(norm,call) },
    "lead" : { (norm:String,call:String) in Leaders(norm,call) },
    "side" : { (norm:String,call:String) in HeadsSides(norm,call) },
    "trail" : { (norm:String,call:String) in Trailers(norm,call) },
    "112" : { (norm:String,call:String) in OneAndaHalf(norm,call) }
  ]

  static let specifier = "\\s*(boys?|girls?|beaus?|belles?|centers?|ends?|leaders?|trailers?|heads?|sides?|very centers?)\\s*"

  let norm:String
  //  Any XML files that might be needed to apply a call
  var requires:[String] { [] }

  static func getCodedCall(_ callname:String) -> CodedCall? {
    let callnorm = TamUtils.normalizeCall(callname)
    //  Most calls can be found by a lookup in one of the maps
    if let simpleCall = simpleCallMaker[callnorm] {
      return simpleCall()
    } else if let complexCall = complexCallMaker[callnorm] {
      return complexCall(callnorm,callname)
    }
    //  More complex cases need to be parsed by a regex
    if (callnorm.matches("(cross)?cloverand(\\w.*)")) {
      return CloverAnd(callnorm,callname)
    }
    //  Be careful not to parse Wheel and Deal and Roll as
    //  Wheel and (Deal and Roll)
    if (callnorm.matches("(reverse)?wheeland(?!deal)(\\\\w.*)")) {
      return WheelAnd(callnorm,callname)
    }
    if (callnorm.matches("out(er|sides?)(2|4|6)?")) {
      return Outsides(callnorm, callname)
    }
    if (callnorm.matches("in(ner|sides?)(2|4|6)?")) {
      return Insides(callnorm,callname)
    }
    if (callnorm.matches("center(2|4|6)")) {
      return Insides(callnorm,callname)
    }
    //  Boys Walk Girls Dodge etc
    //  Also handles Heads Boy Walk Girl Dodge
    if (callnorm.matches("\(specifier)walk(and)?\(specifier)dodge")) {
      return WalkandDodge(callnorm,callname)
    }
    //  Head Boy Walk Head Girl Dodge etc
    if (callnorm.matches("\(specifier)\(specifier)walk(and)?\(specifier)\(specifier)dodge")) {
      return WalkandDodge(callnorm,callname)
    }
    if (callnorm.matches("(left)?spinthewindmill(left|right|in|out|forward)")) {
      return SpinTheWindmill(callnorm,callname)
    }
    if (callnorm.matches("_windmill(in|out|left|right|forward)")) {
      return Windmillx(callnorm,callname)
    }
    if (callnorm.matches("(left)?squarethru(1|2|3|4|5|6|7)?")) {
      return SquareThru(callnorm,callname)
    }
    if (callnorm.matches("(left)?splitsquarethru(2|3|4|5|6|7)?")) {
      return SplitSquareThru(callnorm,callname)
    }
    if (callnorm.matches("(head|side)start.+")) {
      //  Don't want to match Sides Star Thru e.g.
      if (callname.lowercased().matches(".*\\bstart\\b.*")) {
        return  HeadsStart(callnorm,callname)
      }
    }
    if (callnorm.matches("circleby.*")) {
      return CircleBy(callnorm,callname)
    }
    if (callnorm.matches("while.+")) {
      return While(callnorm,callname)
    }
    if (callnorm.matches("(inside|outside|inpoint|outpoint|tandembased|wavebased)?trianglecirculate")) {
      return TriangleCirculate(callnorm,callname)
    }
    if (callnorm.matches(".*chainthru")) {
      if (callnorm.matches(".*squarechainthru")) {
        return nil
      }
      return AnythingChainThru(callnorm,callname)
    }
    if (callnorm.matches("minibusybut.*")) {
      return MiniBusyBut(callnorm,callname)
    }

    if (callnorm.matches("(and)?spread")) {
      return Spread(callnorm,callname)
    }

    return nil
  }

  init(_ norm:String, _ name:String = "") {
    self.norm = norm
    super.init(name.isEmpty ? norm.capWords() : name)
  }

}
