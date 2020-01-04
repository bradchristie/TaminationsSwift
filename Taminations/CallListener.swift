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

import UIKit

class CallListener : NSObject, OEEventsObserverDelegate {

  private let callHandler:(String)->()
  private let errorHandler:(String)->()
  private let openEarsEventsObserver = OEEventsObserver()
  private var initialized = false

  init(callHandler:@escaping (String)->(),errorHandler:@escaping (String)->()) {
    self.callHandler = callHandler
    self.errorHandler = errorHandler
  }

  @discardableResult
  func initializeSpeechRecognizer() -> Bool {
    if (initialized) {
      OEPocketsphinxController.sharedInstance().resumeRecognition()
    } else {
      try! OEPocketsphinxController.sharedInstance().setActive(true)
      let lmPath = Bundle.main.path(forResource: "1958", ofType: "lm", inDirectory: "files/sync")!
      let dicPath = Bundle.main.path(forResource: "1958", ofType: "dic", inDirectory: "files/sync")!
      OEPocketsphinxController.sharedInstance().doNotWarnAboutPermissions = true
      OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(
        atPath: lmPath,
        dictionaryAtPath: dicPath,
        acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"),
        languageModelIsJSGF: false)
      openEarsEventsObserver.delegate = self
      initialized = true
    }
    return true
  }

  func pocketsphinxDidReceiveHypothesis(_ hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
    callHandler(hypothesis!)
  }

  func pause() {
    OEPocketsphinxController.sharedInstance().suspendRecognition()
  }

}
