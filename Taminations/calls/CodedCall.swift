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
    "around1toaline" : { AroundToALine("around1toaline","Around One to a Line") },
    "around2toaline" : { AroundToALine("around2toaline","Around Two to a Line") },
    "around1andcomeintothemiddle" : {  AroundToALine("around1andcomeintothemiddle",
          "Around One and Come Into the Middle") },
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
    "12tag" : { HalfTag("halftag","Half Tag") },
    "left12tag" : { HalfTag("lefthalftag","Left Half Tag") },
    "hinge" : { Hinge("hinge","Hinge") },
    "singlehinge" : { Hinge("hinge","Single Hinge") },
    "partnerhinge" : { Hinge("hinge","Partner Hinge") },
    "lefthinge" : { Hinge("lefthinge","Left Hinge") },
    "leftpartnerhinge" : { Hinge("lefthinge","Left Partner Hinge") },
    "ladies" : { Girls() },
    "jaywalk" : { Jaywalk() },
    "12" : { Fraction("12","Half") },
    "12sashay" : { HalfSashay("12sashay","Half Sashay") },
    "reverse12sashay" : { HalfSashay("reverse12sashay","Reverse Half Sashay") },
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
    "14tag" : { QuarterTag("quartertag","Quarter Tag") },
    "left14tag" : { QuarterTag("leftquartertag","Left Quarter Tag") },
    "ramble" : { Ramble() },
    "run" : { Run("run","Run") },
    "runright" : { Run("runright","Run Right") },
    "runleft" : { Run("runleft","Run Left") },
    "scootandramble" : { ScootAndRamble() },
    "separate" : { Separate() },
    "slideleft" : { SlideDir("slideleft","Slide Left") },
    "slideright" : { SlideDir("slideright","Slide Right") },
    "slidein" : { SlideDir("slidein","Slide In") },
    "slideout" : { SlideDir("slideout","Slide Out") },
    "slidethru" : { SlideThru() },
    "slip" : { Slip() },
    "slide" : { Slide() },
    "swing" : { Swing() },
    "slither" : { Slither() },
    "squeeze" : { Squeeze() },
    "squeezethehourglass" : { SqueezeTheHourglass() },
    "squeezethegalaxy" : { SqueezeTheGalaxy() },
    "starthru" : { StarThru("starthru","Star Thru") },
    "steptoacompactwave" : { StepToACompactWave("","") },
    "steptoacompactlefthandwave" : { StepToACompactWave("left","") },
    "leftstarthru" : { StarThru("leftstarthru","Left Star Thru") },
    "step" : { Step() },
    "stepahead" : { Step() },
    "switchtheline" : { SwitchTheLine() },
    "tagtheline" : { TagTheLine() },
    "32aceydeucey" : { ThreeByTwoAceyDeucey() },
    "34tag" : { ThreeQuartersTag("34tag","3/4 Tag the Line") },
    "34tagtheline" : { ThreeQuartersTag("34tag","3/4 Tag the Line") },
    "left34tag" : { ThreeQuartersTag("left34tag","Left 3/4 Tag the Line") },
    "left34tagtheline" : { ThreeQuartersTag("left34tag","Left 3/4 Tag the Line") },
    "touch" : { Touch("touch","Touch") },
    "lefttouch" : { Touch("lefttouch","Left Touch") },
    "trade" : { Trade() },
    "partnertrade" : { Trade() },
    "thosewhocan" : { ThoseWhoCan() },
    "touch14" : { TouchAQuarter("touch14","Touch a Quarter") },
    "lefttouch14" : { TouchAQuarter("lefttouch14","Left Touch a Quarter") },
    "triplestarthru" : { TripleStarThru() },
    "tripletrade" : { TripleTrade() },
    "turnback" : { TurnBack() },
    "uturnback" : { TurnBack() },
    "twisttheline" : { TwistAnything("twisttheline","Twist the Line") },
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
    "zing" : { Zing() },
    "toawave" : { ToAWave() },
    "kickoff" : { KickOff() },
    "singlecrossandwheel" : { SingleCrossAndWheel() },
    "crossandwheel" : { CrossAndWheel() },
    "crosstradeandwheel" : { CrossTradeAndWheel() },
    "grandcrosstradeandwheel" : { GrandCrossTradeAndWheel() },
    "singlecrosstradeandwheel" : { SingleCrossTradeAndWheel() },
    "bendtheline" : { BendTheLine() },
    "diamondcirculate" : { DiamondCirculate() },
    "everyone" : { Everyone("everyone","Everyone") },
    "everybody" : { Everyone("everybody","Everybody") },
    "shazam" : { Shazam() },
    "counterrotate" : { CounterRotate() },
    "snapthelock" : { SnapTheLock() },
    "castoff34" : { CastOffThreeQuarters() },
    "peeltoadiamond" : { PeelToADiamond() },
    "hocuspocus" : { HocusPocus() },
    "explode" : { Explode() },
    "crossramble" : { CrossRamble() },
    "castback" : { CastBack("castback","Cast Back") },
    "crosscastback" : { CastBack("crosscastback","Cross Cast Back") },
    "horseshoeturn" : { HorseshoeTurn() },
    "scootandcrossramble" : { ScootAndCrossRamble() }
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
  private let _name:String
  override var name: String { get { _name } }

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
    if (callnorm.matches("(reverse)?wheeland(?!deal)(\\w.*)")) {
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
    if (callnorm.matches("(left)?squarethru(1|2|3|4|5|6|7)?(toawave)?")) {
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
    if (callnorm.matches("minibusybut.*")) {
      return MiniBusyBut(callnorm,callname)
    }

    if (callnorm.matches("(and)?spread")) {
      return Spread(callnorm,callname)
    }

    if (callnorm.matches("(left)?(split)?catch(1|2|3|4)")) {
      return Catch(callnorm,callname)
    }

    if callnorm.matches("butterfly.*") {
      return Butterfly(callnorm,callname)
    }

    if (callnorm.matches("zipcode\\d")) {
      return ZipCode(callnorm,callname)
    }

    if (callnorm.matches("twistand.*")) {
      return TwistAnything(callnorm,callname)
    }

    if (callnorm.matches("ascouples.*")) {
      return AsCouples(callnorm,callname)
    }

    if (callnorm.matches("tandem.*")) {
      return TandemConcept(callnorm,callname)
    }

    if (callnorm.matches("siamese.*")) {
      return SiameseConcept(callnorm,callname)
    }

    if (callnorm.matches("(12|34)?crazy.*")) {
      return Crazy(callnorm,callname)
    }

    if (callnorm.matches("(left)?verticaltagback(toawave)?")) {
      return VerticalTagBack(callnorm,callname)
    }

    if (callnorm.matches("(left)?vertical(left)?(14|12|34)?tag")) {
      return VerticalTag(callnorm,callname)
    }

    if (callnorm.matches("adjustto.*")) {
      return Adjust(callnorm,callname)
    }

    if (callnorm.matches("bouncethe.*")) {
      return Bounce(callnorm,callname)
    }

    if (callnorm.matches("(left)?tagback(toawave)?")) {
      return TagBack(callnorm,callname)
    }

    if (callnorm.matches("transferand(.+)")) {
      return TransferAnd(callnorm,callname)
    }

    if (callnorm.matches("(left)?turnanddeal")) {
      return TurnAndDeal(callnorm,callname)
    }

    if (callnorm.matches("phantom(.+)")) {
      return PhantomConcept(callnorm,callname)
    }

    if (callnorm.matches("relocate.+")) {
      return Relocate(callnorm,callname)
    }

    if (callnorm.matches("(outside|point)?(out|in|left|right|(go)?(forward|asyouare))?little")) {
      return Little(callnorm, callname)
    }

    if (callnorm.matches("little(outside|point)(in|out|left|right|(go)?(forward|asyouare))?")) {
      return Little(callnorm,callname)
    }

    if (callnorm.matches("(reverse)?truck")) {
      return Truck(callnorm,callname)
    }

    if (callnorm.matches("swingandcircle(12|34)?")) {
      return SwingAndCircle(callnorm,callname)
    }

    if (callnorm.matches("concentric(.+)")) {
      return ConcentricConcept(callnorm,callname)
    }

    if (callnorm.matches("stretch(.+)")) {
      return StretchConcept(callnorm,callname)
    }

    if (callnorm.matches("checkpoint(.+)by(.*)")) {
      return CheckpointConcept(callnorm,callname)
    }

    if (callnorm.matches("(left|right|in|out)loop(1|2|3)")) {
      return Loop(callnorm,callname)
    }

    if (callnorm.matches("stagger(.+)")) {
      return StaggerConcept(callnorm,callname)
    }

    if (callnorm.matches("(left)?tagyour((criss)?cross)?neighbor")) {
      return TagYourNeighbor(callnorm,callname)
    }

    if (callnorm.matches("castashadowcenter(go|cast)?34")) {
      return CastAShadow(callnorm,callname)
    }

    if (callnorm.matches("finish.*")) {
      return Finish(callnorm,callname)
    }

    if (callnorm.matches(".*(motivate|coordinate|percolate|perkup)")) {
      return AnythingConcept(callnorm,callname)
    }

    if (callnorm.matches("\\d\\d")) {
      return Fraction(callnorm,callname)
    }

    if (callname.lowercased().matches("o .+")) {
      return OFormation(callnorm,callname)
    }

    if (callnorm.matches("triplebox.*")) {
      return TripleBoxConcept(callnorm,callname)
    }

    if (callnorm.matches("triple(lines?|waves?|columnns?).*")) {
      return TripleLineConcept(callnorm,callname)
    }

    if (callnorm.matches(".*chainthru")) {
      if (callnorm.matches(".*squarechainthru")) {
        return nil
      }
      return AnythingChainThru(callnorm,callname)
    }

    //  Start should not match Star Thru e.g.
    if (callname.lowercased().matches("start .+")) {
      return Start(callnorm,callname)
    }

    return nil
  }

  init(_ norm:String, _ name:String) {
    self.norm = norm
    _name = name
  }

  init(_ name:String) {
    self.norm = TamUtils.normalizeCall(name)
    _name = name
  }

}
