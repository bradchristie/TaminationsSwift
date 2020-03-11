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

class SequencerModel {

  private let seqView:SequencerLayout
  private let callsView:SequencerCallsPage

  private var formation = Setting("Starting Formation").s ?? "Static Square"
  private var callBeats:[Double] = []
  var callNames:[String] = []
  private let boyNames:[String] = ["Adam","Brad","Carl","David",
                                   "Eric","Frank",
                                   "Gary","Hank",
                                   "John","Kevin","Larry",
                                   "Mark","Paul","Ray","Scott","Tim","Wally"]
  private let girlNames:[String] = ["Alice","Barb","Carol","Donna",
                                    "Helen", "Karen","Irene","Janet","Linda","Mary","Nancy",
                                    "Pam","Ruth","Susan","Tina","Wanda"]
  private var callListener = CallListener( callHandler:{ _ in }, errorHandler:{ _ in } )

  init(_ seqView:SequencerLayout, _ callsView:SequencerCallsPage) {
    self.seqView = seqView
    self.callsView = callsView
    self.callListener = CallListener(callHandler: { call in self.loadOneCall(call) },
      errorHandler: { error in self.showError(error) } )
    startSequence()
    callsView.textInput.returnAction {
      let call = self.callsView.textInput.text
      if (!call.isBlank) {
        self.callsView.clearError()
        switch (call.lowercased().trim()) {
          case "undo": self.undoLastCall()
          case "reset": self.reset()
          case "copy": self.copyCallsToClipboard()
          case "paste": self.pasteCallsFromClipboard()
          default: self.loadOneCall(call)
        }
        callsView.textInput.text = ""
      }
    }
  }

  func listen(_ on:Bool) {
    if (on) {
      callListener.initializeSpeechRecognizer()
      callsView.textInput.disable()
      callsView.mike.color = UIColor.red
      callsView.mikeButton.invalidate()
    } else {
      callListener.pause()
      callsView.mike.color = UIColor.black
      callsView.mikeButton.invalidate()
      callsView.textInput.enable()
      callsView.textInput.focus()
    }
  }

  func reset() {
    seqView.animationView.doPause()
    callNames = []
    callBeats = []
    callsView.clear()
    startSequence()
  }

  private func showError(_ error:String) {
    callsView.errorText.text = error
    callsView.errorText.show()
    Application.app.sendMessage(.SEQUENCER_ERROR, ("error" , error))
  }

  func checkStartingFormation() {
    if let f = Setting("Starting Formation").s {
      if (f != formation) {
        formation = f
        reset()
      }
    }
  }

  func startSequence() {
    seqView.animationView.setAnimation(TamUtils.getFormation(formation))
    setDancerNames()
    seqView.animationView.readSequencerSettings()
    updateParts()
  }

  private func setDancerNames() {
    var boys = boyNames.shuffled()
    var girls = girlNames.shuffled()
    seqView.animationView.dancers.forEach { it in
      if (it.gender == .BOY) {
        it.name = boys.removeFirst()
      } else if (it.gender == .GIRL) {
        it.name = girls.removeFirst()
      }
    }
  }

  private func insertCall(_ call:String) {
    if (interpretOneCall(call)) {
      updateParts()
      seqView.animationView.goToPart(callNames.count-1)
      seqView.animationView.doPlay()
      seqView.panelLayout.playButton.setImage(PauseShape())
    } else {
      callNames.remove(at:callNames.count-1)
    }
  }

  @discardableResult
  private func interpretOneCall(_ calltext:String) -> Bool {
    //  Remove any underscores, which are reserved for internal calls only
    let calltxt = calltext.replace("_","")
    //  Add call as entered, in case parsing fails
    let line = callNames.count
    callNames.append(calltxt)
    let avdancers = seqView.animationView.dancers
    let cctx = CallContext(avdancers)
    do {
      let prevbeats = seqView.animationView.movingBeats
      try cctx.interpretCall(calltxt)
      try cctx.performCall()
      cctx.checkForCollisions()
      cctx.extendPaths()
      cctx.matchStandardFormation()
      cctx.appendToSource()
      seqView.animationView.recalculate()
      let newbeats = seqView.animationView.movingBeats
      if (newbeats > prevbeats) {
        //  Call worked, add it to the list
        callsView.addCall(calltxt.capWords(),level:cctx.level)
        callNames[line] = cctx.callname
        callBeats.append(newbeats - prevbeats)
        //callsView.highlightCall(line) gets highlighted later
      }
    } catch let err as CallError {
      showError(err.msg)
      return false
    } catch _ {
      //  This callback cannot throw so any exception needs to be handled here
    }
    return true
  }

  //  Update parts and tics on animation panel
  private func updateParts() {
    if (callBeats.count > 1) {
      let partstr = callBeats.count > 1 ? callBeats.dropLast().map { "\($0)" } .joined(separator: ";") : ""
      seqView.animationView.partsstr = partstr
    } else {
      seqView.animationView.partsstr = ""
    }
    seqView.panelLayout.ticView.setTics(seqView.animationView.totalBeats,
      partstr:seqView.animationView.partsstr, isCalls: true)
    seqView.beatText.text = seqView.animationView.movingBeats.i.s
    /*
    if (callNames.isNotEmpty()) {
      Application.app.updateLocation(Request.Action.SEQUENCER,
        ("formation" , formation),
        ("calls" , callNames.joined(separator:";")))
    } else {
      Application.app.updateLocation(Request.Action.SEQUENCER,
        ("formation" , formation), ("calls" , "delete"))
    }  */
  }

  func undoLastCall() {
    if (callNames.isNotEmpty()) {
      let lastIndex = callNames.count - 1
      callNames.remove(at:lastIndex)
      callBeats.remove(at:lastIndex)
      let totalBeats = callBeats.reduce(0, { x,y in x+y })
      seqView.animationView.dancers.forEach { d in
        while (d.path.beats > totalBeats) {
          d.path.pop()
        }
      }
      seqView.animationView.recalculate()
      seqView.animationView.doEnd()
      callsView.removeLastCall()
      updateParts()
    }
  }

  func toast(title:String="", message:String="", delay:TimeInterval=4) {
    let toastview = UIAlertView(title: title, message:message, delegate: nil, cancelButtonTitle: nil)
    toastview.translatesAutoresizingMaskIntoConstraints = false
    toastview.show()
    TamUtils.runAfterDelay(delay) {
      toastview.dismiss(withClickedButtonIndex: 0, animated: true)
    }
  }

  func copyCallsToClipboard() {
    let pb = UIPasteboard(name:.general,create:false)!
    pb.string = callNames.joined(separator:"\n")
    toast(title:"\(callNames.count) Calls copied to clipboard",delay:2)
  }

  //  Replace any abbreviations
  private func getAbbrevs(_ str:String) -> String {
    str.split().map { s in
      Storage["abbrev "+s.lowercased()] ?? s
    }.joined(separator:" ")
  }

  func loadOneCall(_ call:String) {
    callsView.clearError()
    CallContext.loadCalls([getAbbrevs(call)])
    insertCall(getAbbrevs(call))
  }

  //  Build sequence from calls either pasted in or in the URL
  func loadCalls(_ calls:[String], _ f:String = "") {
    if (f.isNotEmpty()) {
      formation = f
    }
    reset()
    CallContext.loadCalls(calls.map { getAbbrevs($0) })
    calls.forEach { call in
      interpretOneCall(call)
    }
    updateParts()
    seqView.animationView.goToPart(-1)
    Application.app.sendMessage(.SEQUENCER_READY)
  }

  func pasteCallsFromClipboard() {
    let pb = UIPasteboard(name:.general,create:false)!
    if (pb.string != nil) {
      let s = pb.string!
      callNames = []
      loadCalls(s.split("\n").filter({ (s:String) -> Bool in
        s.matches(".*\\w.*")
      }))
    }
  }

}
