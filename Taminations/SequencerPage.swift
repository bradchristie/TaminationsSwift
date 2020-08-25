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

class SequencerPage : Page {

  private let callPage = SequencerCallsPage()
  private let instrPage = SequencerInstructionPage()
  private let settingsPage = SequencerSettingsPage()
  private let abbrPage = AbbreviationsPage()
  private let refpage = SequencerReferencePage()
  private let rightPage = NavigationPage()
  private let seqView = SequencerLayout()
  private let _view:LinearLayout
  override var view:View { return _view }
  private let model:SequencerModel
  private let panelModel:AnimationPanelModel

  override init() {
    if (Application.isLandscape) {
      _view = LinearLayout(.HORIZONTAL)
      callPage.view.weight = 1
      callPage.view.fillVertical()
      _view.appendView(callPage.view)
      _view.appendView(seqView)
      seqView.weight = 1
      seqView.fillVertical()
      _view.appendView(rightPage.view)
      rightPage.view.weight = 1
      rightPage.view.fillVertical()
    } else {
      _view = LinearLayout(.VERTICAL)
      seqView.weight = 3
      seqView.fillHorizontal()
      _view.appendView(seqView)
      callPage.view.weight = 1
      callPage.view.fillHorizontal()
      _view.appendView(callPage.view)
    }
    rightPage.pages += [instrPage,settingsPage,abbrPage,refpage]
    model = SequencerModel(seqView,callPage)
    panelModel = AnimationPanelModel(seqView.panelLayout,seqView.animationView)
    super.init()

    onAction(.SEQUENCER) { request in
      Application.app.titleBar.title = "Sequencer"
      CallContext.loadInitFiles()
      self.rightPage.doRequest(.SEQUENCER_INSTRUCTIONS, request)
    //  self.model.startSequence()
      self.callPage.textInput.focus()
    }
    onMessage(.BUTTON_PRESS) { request in
      switch (request["id"]!) {
        case "Sequencer Help" : self.sequencerRequest(.SEQUENCER_INSTRUCTIONS)
        case "Sequencer Settings" : self.sequencerRequest(.SEQUENCER_SETTINGS)
        case "Sequencer Abbrev" : self.sequencerRequest(.SEQUENCER_ABBREVIATIONS)
        case "Sequencer Calls" : self.sequencerRequest(.SEQUENCER_CALLS)
        case "Sequencer Undo": self.model.undoLastCall()
        case "Sequencer Reset" : self.model.reset()
        case "Sequencer Copy" : self.model.copyCallsToClipboard()
        case "Sequencer Paste" : self.model.pasteCallsFromClipboard()
        default : break
      }
    }
    onMessage(Request.Action.ANIMATION_PROGRESS) { message in
      let beat = message["beat"]!.d
      self.seqView.panelLayout.beatSlider.setValue(beat*100.0/self.seqView.animationView.totalBeats)
    }
    onMessage(Request.Action.ANIMATION_PART) { message in
      let partnum = message["part"]!.i-1
      let listnum = self.model.callNum2listNum(partnum)
      self.callPage.highlightCall(listnum)
      self.seqView.callText.textSize = min(24,self.seqView.animationView.height/5)
      self.seqView.callText.text = (listnum >= 0 && partnum < self.model.callNames.count)
        ? self.model.callNames[listnum]
        : ""
    }
    onMessage(Request.Action.ANIMATION_DONE) { message in
      self.seqView.panelLayout.playButton.setImage(PlayShape())
    }

    onMessage(Request.Action.SETTINGS_CHANGED) { message in
      self.seqView.animationView.readSequencerSettings()
      self.model.checkStartingFormation()
    }
    onMessage(Request.Action.SEQUENCER_CURRENTCALL) { message in
      let callnum = self.model.listNum2callNum(message["item"]!.i)
      if (callnum > 0) {
        self.seqView.animationView.goToPart(callnum)
      }
    }
    onMessage(Request.Action.TRANSITION_COMPLETE) { messsage in
      self.callPage.textInput.focus()
    }
    onMessage(Request.Action.CALLITEM) { request in
      self.model.loadOneCall(request["title"]!)
    }
    onMessage(Request.Action.SEQUENCER_LISTEN) { message in
      self.model.listen(self.callPage.listening)
    }
    onMessage(Request.Action.RESOLUTION_ERROR) { message in
      self.callPage.errorText.text = "Warning: Dancers are not resolved."
      self.callPage.errorText.show()
    }
  }

  private func sequencerRequest(_ action:Request.Action) {
    if (Application.isLandscape) {
      rightPage.doRequest(action)
    } else {
      Application.app.sendRequest(action)
    }
  }

  override func sendMessage(_ message: Request) {
    super.sendMessage(message)
    if (Application.isLandscape) {
      rightPage.sendMessage(message)
    }
  }

}
