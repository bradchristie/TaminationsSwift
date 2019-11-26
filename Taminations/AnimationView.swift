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

enum SpeedValues:Double {
  case slowspeed = 1500
  case moderatespeed = 1000
  case normalspeed = 500
  case fastspeed = 200
}

class AnimationView : Canvas {

  private var lasttime:Int64 = 0
  var beat = 0.0    //  current beat
  private var beats = 0.0   //  total beats of current animation -
      // includes leadout but not leadin
  private var leadin = 2.0  //  beats to wait before starting animation
  private var leadout = 2.0  // beats to add at end of animation
  private var geometry:GeometryType = .SQUARE
  var isRunning = false
  private var iscore = 0.0  // for practice mode
  private var prevbeat = -2.0
  var dancers:[Dancer] = []
  private var interactiveDancer = -1
  private var interactiveRandom = false
  private var idancer:InteractiveDancer?
  var partsstr = ""
  private var showGrid = false
  private var showPaths = false
  private var showPhantoms = false
  private var randomColors = false
  private var looping = false
  private var speed:SpeedValues = .normalspeed
  private var tam:XMLElement? = nil
  private var currentPart = 0
  var hasParts = false
  private var randomColorArray = [
    UIColor.black,
    UIColor.blue,
    UIColor.cyan,
    UIColor.gray,
    UIColor.green,
    UIColor.magenta,
    UIColor.orange,
    UIColor.red,
    UIColor.white,
    UIColor.yellow
  ]

  override init() {
    super.init()
    touchDownAction { _,x,y in
      let (dx,dy) = self.mouse2dancer(x,y)
      self.doTouch(dx,dy)
    }
  }

  private func setInteractiveDancerControls() {
    touchDownAction { id,x,y in
      let (dx, dy) = self.mouse2dancer(x, y)
      self.idancer?.touchDown(id, x:dx, y:dy) ?? self.doTouch(dx, dy)
    }
    touchUpAction { id,_,_ in
      self.idancer?.touchUp(id)
    }
    touchMoveAction {
      id,x,y in
      let (dx, dy) = self.mouse2dancer(x, y)
      self.idancer?.touchMove(id, x:dx, y:dy)
    }
  }


  /**
   *   Starts the animation
   */
  func doPlay() {
    lasttime = Application.currentTime()
    if (beat > beats) {
      beat = -leadin
    }
    isRunning = true
    iscore = 0.0
    if (idancer != nil) {
      setInteractiveDancerControls()
    }
    invalidate()
  }

  /**
   * Pauses the dancers update & animation.
   */
  func doPause() { isRunning = false }

  /**
   *  Rewinds to the start of the animation, even if it is running
   */
  func doRewind() {
    beat = -leadin
    invalidate()
  }

  /**
   *   Moves to the end of the animation
   */
  func doEnd() {
    beat = beats
    invalidate()
  }

  /**
   *   Moves the animation back a little
   */
  func doBackup() {
    beat = max(beat-0.1, -leadin)
    invalidate()
  }

  /**
   *   Moves the animation forward a little
   */
  func doForward() {
    beat = min(beat+0.1, beats)
    invalidate()
  }

  /**
   *   Build an array of floats out of the parts of the animation
   */
  func partsValues() -> [Double] {
    if (partsstr.count == 0) {
      return [-2,0]
    } else {
      var b = 0.0
      let t = partsstr.split(";")
      var retval = [Double]()
      retval.append(-leadin)
      retval.append((0))
      for i in 0 ..< t.count {
        b = b + t[i].d
        retval.append(b)
      }
      return retval
    }
  }

  /**
   *   Moves the animation to the next part
   */
  func doNextPart() {
    if (beat < beats) {
      let pv = partsValues().filter({$0 > beat})
      beat = pv.count > 0 ? pv[0] : beats
      invalidate()
    }
  }

  /**
   *   Moves the animation to the previous part
   */
  func doPrevPart() {
    if (beat > -leadin) {
      let pv = partsValues().reversed().filter({$0 < beat})
      beat = pv.count > 0 ? pv[0] : 0
      invalidate()
    }
  }

  /**
   *   Go to a specific part.
   *   The first part is 0.
   */
  func goToPart(_ i:Int) {
    let pv = partsValues()
    beat = pv[min(i+1,pv.count-1)] + 0.01  // skip leadin
    invalidate()
  }

  /**
 *   Set the visibility of the grid
 */
  func setGridVisibility(_ show:Bool) {
    showGrid = show
    invalidate()
  }

  /**
   *   Set the visibility of phantom dancers
   */
  private func setPhantomVisibility(_ show:Bool) {
    showPhantoms = show
    dancers.forEach { d in d.hidden = d.isPhantom && !show }
    invalidate()
  }

  /**
   *  Turn on drawing of dancer paths
   */
  private func setPathVisibility(_ show:Bool) {
    showPaths = show
    invalidate()
  }

  /**
   *   Set animation looping
   */
  private func setLoop(_ loopit:Bool) {
    looping = loopit
    invalidate()
  }

  /**
   *   Set display of dancer numbers
   */
  private func setNumbers(_ numberem:Int) {
    let n = (interactiveDancer >= 0) ? Dancer.NUMBERS_OFF : numberem
    dancers.forEach { d in d.showNumber = n }
    invalidate()
  }
  private func setNumbers(_ numberstr:String) {
    switch (numberstr) {
      case "Dancers" : setNumbers(Dancer.NUMBERS_DANCERS)
      case "Couples" : setNumbers(Dancer.NUMBERS_COUPLES)
      default : setNumbers(Dancer.NUMBERS_OFF)
    }
  }

  private func setColors(_ isOn:Bool) {
    dancers.forEach { d in
      d.showColor = isOn
      if let cname = Setting("Couple \(d.number_couple)").s {
        d.fillcolor = UIColor.colorForName(cname)
      } else {
        d.fillcolor = dancerColor[d.number_couple.i]
      }
    }
    invalidate()
  }
  private func setShapes(_ isOn:Bool) {
    dancers.forEach { d in d.showShape = isOn }
    invalidate()
  }

  private var dancerColor:[UIColor] {
    if (geometry == .HEXAGON) {
      return
        [UIColor.lightGray,UIColor.red,UIColor.green,UIColor.magenta,
         UIColor.blue,UIColor.yellow,UIColor.cyan,
         UIColor.lightGray,UIColor.lightGray,UIColor.lightGray,UIColor.lightGray]
    }
    //  Except for the phantoms, these are the standard colors
    //  used for teaching callers
    return
      [UIColor.lightGray,UIColor.red,UIColor.green, UIColor.blue,UIColor.yellow,
      UIColor.lightGray,UIColor.lightGray,UIColor.lightGray,UIColor.lightGray]
  }

  private func setRandomColors() {
    randomColorArray.shuffle()
    dancers.enumerated().forEach { (i,dancer) in
      dancer.showColor = true
      dancer.fillcolor = dancer.gender == .PHANTOM
        ? UIColor.lightGray : randomColorArray[i]
    }
  }

  /**
   *   Set speed of animation
   */
  func setSpeed(_ myspeed:String) {
    switch myspeed {
    case "Slow" : speed = .slowspeed
    case "Moderate" : speed = .moderatespeed
    case "Fast" : speed = .fastspeed
    default : speed = .normalspeed
    }
  }

  private func setNewGeometry(_ g:GeometryType) {
    if (geometry != g) {
      geometry = g
      resetAnimation()
    }
  }

  var totalBeats:Double { return leadin + beats }
  var movingBeats:Double { return beats - leadout }
  var score:Double { return iscore }


  /**
   *   Set time of animation as offset from start including leadin
   */
  func setTime(_ b:Double) {
    beat = b - leadin
    invalidate()
  }

  //  Convert x and y to dance floor coords
  private func mouse2dancer(_ x:Int, _ y:Int) -> (Double,Double) {
    let range = min(width,height)
    let s = range.d / 13.0
    let dx = -(y.d - height.d / 2.0) / s
    let dy = -(x.d - width.d / 2.0) / s
    return (dx,dy)
  }

  //  Touching a dancer shows and hides its path
  private func doTouch(_ dx:Double, _ dy:Double) {
    //  Compare touch point with dancer locations
    let v = Vector(dx,dy)
    let bestdq = dancers.min { d1,d2 in
      (d1.location-v).length < (d2.location-v).length
    }
    if let bestd = bestdq {
      if ((bestd.location - v).length < 0.5) {
        bestd.showPath = !bestd.showPath
        invalidate()
      }
    }
  }

  private func isInteractiveDancerOnTrack() -> Bool {
    //  Get where the dancer should be
    let computetx = idancer!.computeMatrix(beat)
    //  Get computed and actual location vectors
    let ivu = idancer!.tx.location
    let ivc = computetx.location
    let spotOK = (ivu - ivc).length < 2.0

    //  Check dancer's facing direction
    let au = idancer!.tx.angle
    let ac = computetx.angle
    let faceOK = angleAngleDiff(au,ac).abs < .pi/4

    //  Check relationship with the other dancers
    let relOK = dancers.filter { $0 != idancer! }.allSatisfy { d in
      let dv = d.tx.location
      //  Compare angle to computed vs actual
      let d2ivu = ivu - dv
      let d2ivc = ivc - dv
      let a = d2ivu.angleDiff(d2ivc)
      return a.abs < .pi/4
    }
    return spotOK && faceOK && relOK
  }

  override func onDraw(_ ctx: DrawingContext) {
    if (tam != nil) {

      //  Update the animation time
      let now = Application.currentTime()
      let diff = Double(now - lasttime)
      if (isRunning) {
        beat += diff / speed.rawValue
      }
      lasttime = now
    }

    //  Move the dancers
    if (dancers.count > 0) {
      updateDancers()
    }
    //  Draw the dancers
    doDraw(ctx)

    //  Remember time of this update, and handle loop and end
    prevbeat = beat
    if (beat >= beats) {
      if (looping && isRunning) {
        prevbeat = -leadin
        beat = -leadin
      } else if (isRunning) {
        isRunning = false
        if (idancer != nil) {
          //  TODO  releaseInteractiveDancerControls()
        }
        Application.app.sendMessage(.ANIMATION_DONE)
      }
    }
    Application.app.sendMessage(Request(.ANIMATION_PROGRESS,
      ("beat", (beat + leadin).s)))
    //  Continually repeat by telling the system to re-draw
    if (isRunning) {
      Application.later {
        self.invalidate()
      }
    }

  }

  func doDraw(_ ctx:DrawingContext) {
    ctx.save()
    //  Draw background
    ctx.fillRect(rect: div.bounds, p: DrawingStyle(color: UIColor.FLOOR))
    let range = min(width, height).d
    let p = DrawingStyle(color: UIColor.black, textSize: range / 15.0)
    //  For interactive leadin, show countdown
    if (idancer != nil && beat < 0.0) {
      let tminus = floor(beat).i.s
      p.textAlign = .BOTTOM
      p.textSize = range / 2.0
      p.color = UIColor.gray
      ctx.fillText(tminus, x: range / 2.0, y: range, p)
    }
    //  Put (0,0) in center and scale coordinate system to dancer's size
    ctx.translate(width.d / 2.0, height.d / 2.0)
    let s = range / 13.0
    //  Flip and rotate so X is to the right and Y is up
    ctx.scale(s, -s)
    ctx.rotate(.pi / 2.0)
    //  Draw grid if on
    if (showGrid) {
      GeometryMaker.makeOne(geometry).drawGrid(ctx)
    }
    //  Always show bigon center mark
    if (geometry == .BIGON) {
      let pline = DrawingStyle(lineWidth: 13.0 / min(width, height).d)
      ctx.drawLine(x1: 0.0, y1: -0.5, x2: 0.0, y2: 0.5, pline)
      ctx.drawLine(x1: -0.5, y1: 0.0, x2: 0.5, y2: 0.0, pline)
    }
    //  Draw paths if requested
    dancers.forEach { d in
      if (!d.hidden && (showPaths || d.showPath)) {
        d.drawPath(ctx)
      }
    }
    //  Draw handholds
    let hline = DrawingStyle(color:UIColor.orange, lineWidth: 0.05)
    dancers.forEach { d in
      let loc = d.location
      if (d.rightHandVisibility) {
        if (d.rightdancer == nil) {  // hexagon center
          ctx.drawLine(x1:loc.x, y1:loc.y, x2:0.0, y2:0.0, hline)
          ctx.fillCircle(x:0.0, y:0.0, radius:0.125, p:hline)
        } else if (d.rightdancer! < d) {
          let loc2 = d.rightdancer!.location
          ctx.drawLine(x1:loc.x, y1:loc.y, x2:loc2.x, y2:loc2.y, hline)
          ctx.fillCircle(x:(loc.x + loc2.x) / 2.0,
            y:(loc.y + loc2.y) / 2.0, radius:0.125, p:hline)
        }
      }
      if (d.leftHandVisibility) {
        if (d.leftdancer == nil) {  // hexagon center
          ctx.drawLine(x1:loc.x, y1:loc.y, x2:0.0, y2:0.0, hline)
          ctx.fillCircle(x:0.0, y:0.0, radius:0.125, p:hline)
        } else if (d.leftdancer! < d) {
          let loc2 = d.leftdancer!.location
          ctx.drawLine(x1:loc.x, y1:loc.y, x2:loc2.x, y2:loc2.y, hline)
          ctx.fillCircle(x:(loc.x + loc2.x) / 2.0,
            y:(loc.y + loc2.y) / 2.0, radius:0.125, p:hline)
        }
      }
    }

    //  Draw dancers
    dancers.filter { !$0.hidden }.forEach { d in
      ctx.save()
      ctx.transform(d.tx)
      d.draw(ctx)
      ctx.restore()
    }

  }

  //  Check that there isn't another dancer in the middle of
  //  a computed handhold.  Can happen when dancers are in
  //  tight formations like tidal waves.
  private func dancerInHandhold(_ hh:Handhold) -> Bool {
    let hhloc = (hh.dancer1.location + hh.dancer2.location).scale(0.5,0.5)
    return dancers.any { d in
         d != hh.dancer1 && d != hh.dancer2 &&
         (d.location - hhloc).length < 0.5
    }
  }

  func updateDancers() {
    //  Move dancers
    //  For big jumps, move incrementally -
    //  this helps hexagon and bigon compute the right location
    let delta = beat - prevbeat
    let incs = ceil(delta.abs).i
    if (incs >= 1) {
      for j in 1...incs {
        dancers.forEach { d in
          d.animate(beat: prevbeat + j.d * delta / incs.d)
        }
      }
    }

    //  Find the current part, and send a message if it's changed
    var thispart = 0
    if (beat >= 0 && beat <= beats) {
      thispart = partsValues().lastIndex(where: { it in it < beat } )!
    }
    if (thispart != currentPart) {
      currentPart = thispart
      Application.app.sendMessage(.ANIMATION_PART,("part",currentPart.s))
    }

    //  Compute handholds
    var hhlist = [Handhold]()
    for d0 in dancers {
      d0.rightdancer = nil
      d0.leftdancer = nil
      d0.rightHandVisibility = false
      d0.leftHandVisibility = false
    }
    for i1 in 0..<dancers.count-1 {
      let d1 = dancers[i1]
      if (!d1.isPhantom || showPhantoms) {
        for i2 in i1+1..<dancers.count {
          let d2 = dancers[i2]
          if (!d2.isPhantom || showPhantoms) {
            if let hh = Handhold.apply(d1, d2, geometry: geometry) {
              hhlist.append(hh)
            }
          }
        }
      }
    }
    //  Sort the array to put best scores first
    hhlist.sort { $0.score < $1.score }
    //  Apply the handholds in order from best to worst
    //  so that if a dancer has a choice it gets the best handhold
    for hh in hhlist.filter( { !dancerInHandhold($0) }) {
      //  Check that the hands aren't already used
      let incenter = geometry == GeometryType.HEXAGON && hh.inCenter()
      if (incenter ||
        (hh.hold1==Hands.RIGHTHAND && hh.dancer1.rightdancer==nil ||
          hh.hold1==Hands.LEFTHAND && hh.dancer1.leftdancer==nil) &&
          (hh.hold2==Hands.RIGHTHAND && hh.dancer2.rightdancer==nil ||
            hh.hold2==Hands.LEFTHAND && hh.dancer2.leftdancer==nil)) {
        //      	Make the handhold visible
        //  Scale should be 1 if distance is 2
        //  float scale = hh.distance/2f;
        if (hh.hold1==Hands.RIGHTHAND || hh.hold1==Hands.GRIPRIGHT) {
          hh.dancer1.rightHandVisibility = true
          hh.dancer1.rightHandNewVisibility = true
        }
        if (hh.hold1==Hands.LEFTHAND || hh.hold1==Hands.GRIPLEFT) {
          hh.dancer1.leftHandVisibility = true
          hh.dancer1.leftHandNewVisibility = true
        }
        if (hh.hold2==Hands.RIGHTHAND || hh.hold2==Hands.GRIPRIGHT) {
          hh.dancer2.rightHandVisibility = true
          hh.dancer2.rightHandNewVisibility = true
        }
        if (hh.hold2==Hands.LEFTHAND || hh.hold2==Hands.GRIPLEFT) {
          hh.dancer2.leftHandVisibility = true
          hh.dancer2.leftHandNewVisibility = true
        }

        if (!incenter) {
          if (hh.hold1 == Hands.RIGHTHAND) {
            hh.dancer1.rightdancer = hh.dancer2
            if ((hh.dancer1.hands.i & Hands.GRIPRIGHT.i) == Hands.GRIPRIGHT.i) {
              hh.dancer1.rightgrip = hh.dancer2
            }
          } else {
            hh.dancer1.leftdancer = hh.dancer2
            if ((hh.dancer1.hands.i & Hands.GRIPLEFT.i) == Hands.GRIPLEFT.i) {
              hh.dancer1.leftgrip = hh.dancer2
            }
          }
          if (hh.hold2 == Hands.RIGHTHAND) {
            hh.dancer2.rightdancer = hh.dancer1
            if ((hh.dancer2.hands.i & Hands.GRIPRIGHT.i) == Hands.GRIPRIGHT.i) {
              hh.dancer2.rightgrip = hh.dancer1
            }
          } else {
            hh.dancer2.leftdancer = hh.dancer1
            if ((hh.dancer2.hands.i & Hands.GRIPLEFT.i) == Hands.GRIPLEFT.i) {
              hh.dancer2.leftgrip = hh.dancer1
            }
          }
        }
      }
    }
    //  Clear handholds no longer visible
    for d in dancers {
      if (d.leftHandVisibility && !d.leftHandNewVisibility) {
        d.leftHandVisibility = false
      }
      if (d.rightHandVisibility && !d.rightHandNewVisibility) {
        d.rightHandVisibility = false
      }
    }

    //  Update interactive dancer score
    if (idancer != nil && beat > 0.0 && beat < beats-leadout) {
      idancer!.onTrack = isInteractiveDancerOnTrack()
      if (idancer!.onTrack) {
        iscore += (beat - max(prevbeat, 0.0)) * 10.0
      }
    }


  }

  /**
   *   This is called to generate or re-generate the dancers and their
   *   animations based on the call, geometry, and other settings.
   * @param xtam     XML element containing the call
   * @param intdan  Dancer controlled by the user, or -1 if not used
   */
  func setAnimation(_ xtam:XMLElement, intdan:Int = -1, intrandom:Bool = true) {
    tam = TamUtils.tamXref(xtam)
    interactiveDancer = intdan
    interactiveRandom = intrandom
    resetAnimation()
    Application.app.sendMessage(.ANIMATION_LOADED)
  }

  func resetAnimation() {
    if let mytam = tam {
      leadin = interactiveDancer < 0 ? 2.0 : 3.0
      leadout = interactiveDancer < 0 ? 2.0 : 1.0
      if (isRunning) {
        Application.app.sendMessage(.ANIMATION_DONE)
        isRunning = false
      }
      beats = 0.0
      let tlist = mytam.children(tag: "formation")
      var formation = mytam
      if (tlist.count > 0) {
        formation = tlist.first!
      } else if let formattr = mytam.attr("formation") {
        formation = TamUtils.getFormation(formattr)
      }
      let flist = formation.children(tag: "dancer")
      dancers = []

      //  Get numbers for dancers and couples
      //  This fetches any custom numbers that might be defined in
      //  the animation to match a Callerlab or Ceder Chest illustration
      let paths = mytam.children(tag: "path")
      var numbers = ["1", "5", "2", "6", "3", "7", "4", "8"]
      if (geometry == .HEXAGON) {
        numbers = ["A", "E", "I",
                   "B", "F", "J",
                   "C", "G", "K",
                   "D", "H", "L",
                   "u", "v", "w", "x", "y", "z"]
      } else if (geometry == .BIGON) {
        numbers = ["1", "2", "3", "4", "5", "6", "7", "8"]
      } else if (paths.count > 0) {
        numbers = TamUtils.getNumbers(mytam)
      }
      var couples = ["1", "3", "1", "3", "2", "4", "2", "4"]
      if (geometry == .HEXAGON) {
        couples = ["1", "3", "5", "1", "3", "5",
          "2", "4", "6", "2", "4", "6",
          "7", "8", "7", "8", "7", "8"]
      } else if (geometry == .BIGON) {
        couples = [ "1", "2", "3", "4", "5", "6", "7", "8" ]
      } else if (paths.count > 0) {
        couples = TamUtils.getCouples(mytam)
      }

      //  TODO randomColorArray.shuffle()
      let geoms = GeometryMaker.makeAll(geometry)

      //  Select a random dancer of the correct gender for the interactive dancer
      var im = Matrix()
      var icount = -1
      if (interactiveDancer > 0) {
        let glist = formation.children(tag:"dancer").filter
          { d in d["gender"] == (interactiveDancer == 1 ? "boy" : "girl") }
        //  Select either the first or random dancer to be interactive
        icount = interactiveRandom ? Int(arc4random_uniform(UInt32(glist.count))) : 0
        //  Find the angle the interactive dancer faces at start
        //  We want to rotate the formation so that direction is up
        let iangle = glist[icount].attr("angle")!.d
        im = im * Matrix(angle: -iangle.toRadians)
        //  Adjust icount for looping through geometry below
        icount = icount * geoms.count + 1
      }

      //  Create the dancers and set their starting positions
      var dnum = 0
      for i in 0..<flist.count {
        let fd = flist[i]
        let x = fd.attr("x")!.d
        let y = fd.attr("y")!.d
        let angle = fd.attr("angle")!.d
        let gender = fd.attr("gender")!
        let g:Gender = gender == "girl" ? .GIRL : gender == "boy" ? .BOY : .PHANTOM
        let movelist = paths.count > i ? TamUtils.translatePath(paths[i]) : []
        //  Each dancer listed in the formation corresponds to
        //  one, two, or three real dancers depending on the geometry
        for geom in geoms {
          let m = im * Matrix(x:x,y:y) * Matrix(angle:angle.toRadians)
          let nstr = (g == Gender.PHANTOM) ? " " : numbers[dnum]
          let cstr = (g == Gender.PHANTOM) ? " " : couples[dnum]
          let colorstr = (g == Gender.PHANTOM) ? " " : couples[dnum]
          let usercolor = Setting("Couple $colorstr").s
          let color = (g == .PHANTOM) ? UIColor.lightGray
            : randomColors ? UIColor.gray
            : usercolor != nil ? UIColor.gray
            : dancerColor[colorstr.i]
          //  add one dancer
          if (g.rawValue == interactiveDancer) {
            icount -= 1
          }
          if (g.rawValue == interactiveDancer  && icount == 0) {
            idancer = InteractiveDancer(number: nstr, couple: cstr, gender: g.rawValue,
              fillcolor: color, mat: m, geom: geom.clone(), moves: movelist)
            dancers.append(idancer!)
          } else {  // not interactive
             dancers.append(Dancer(number: nstr, couple: cstr, gender: g.rawValue,
               fillcolor: color, mat: m, geom: geom.clone(), moves: movelist))
          }
          if (g == .PHANTOM && !showPhantoms) {
            dancers.last().hidden = true
          }
          beats = max(beats,dancers.last().beats+leadout)
          dnum += 1
        }
      }  // all dancers added

      //  Initialize other instance variables
      partsstr = (mytam.attr("parts") ?? "") + (mytam.attr("fractions") ?? "")
      hasParts = mytam.attr("parts") != nil
      isRunning = false
      beat = -leadin
      prevbeat = -leadin
      invalidate()
    }   //  if we have a tam
  }


  func recalculate() {
    beats = 0.0
    dancers.forEach { d in
      beats = max(beats, d.beats + leadout)
    }
  }

  func readAnimationSettings() {
    setNewGeometry(GeometryMaker.makeOne(Setting("Special Geometry").s ?? "None").geometry())
    setGridVisibility(Setting("Grid").b == true)
    setLoop(Setting("Loop").b == true)
    setPathVisibility(Setting("Paths").b == true)
    setSpeed(Setting("Dancer Speed").s ?? "Normal")
    setNumbers(Setting("Numbers").s ?? "None")
    setPhantomVisibility(Setting("Phantoms").b == true)
    setColors(true)
    setShapes(true)
    invalidate()
  }

  func readSequencerSettings() {
    setNewGeometry(GeometryMaker.makeOne("None").geometry())
    setGridVisibility(Setting("Grid").b == true)
    setLoop(false)
    setPathVisibility(false)
    setSpeed(Setting("Dancer Speed").s ?? "Normal")
    switch (Setting("Dancer Identification").s ?? "None") {
      case "Numbers" : setNumbers(Dancer.NUMBERS_DANCERS)
      case "Couples" : setNumbers(Dancer.NUMBERS_COUPLES)
      case "Names" : setNumbers(Dancer.NUMBERS_NAMES)
      default : setNumbers(Dancer.NUMBERS_OFF)
    }
    setPhantomVisibility(false)
    switch (Setting("Dancer Colors").s ?? "") {
      case "None" : setColors(false)
      case "Random" : setRandomColors()
      default : setColors(true)
    }
    setShapes(Setting("Dancer Shapes").b != false)
    invalidate()
  }

}
