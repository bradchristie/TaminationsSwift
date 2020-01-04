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

class TitleBar : LinearLayout {

  private let titleView = TextView("Taminations")
  private let backButton = Button("  Back  ")
  private let levelButton = Button("  ")
  private var hasAudio = false
  private let speakerButton = ImageButton(SpeakerShape())
  private var audioPlayer: AVAudioPlayer?
  private let grad = CAGradientLayer()

  init() {
    super.init(.HORIZONTAL)
    backButton.weight = 0
    backButton.topMargin = 10
    backButton.alignCenter()
    backButton.clickAction {
      Application.app.goBack()
    }
    backButton.longPressAction {
      Application.app.sendRequest(.STARTUP)
    }
    appendView(backButton)
    titleView.textColor = UIColor.white
    titleView.textSize = 48.pp
    titleView.textStyle = "bold"
    titleView.wrap()
    titleView.alignMiddle().alignCenter() //.fillVertical()
    titleView.topMargin = 10
    titleView.shadow()
    titleView.weight = 1
    appendView(titleView)
    speakerButton.weight = 0
    speakerButton.topMargin = 10
    speakerButton.alignCenter()
    appendView(speakerButton)
    levelButton.weight = 0
    levelButton.topMargin = 10
    levelButton.alignCenter()
    levelButton.clickAction {
      Application.app.sendRequest(.CALLLIST,("level",self.levelButton.text))
    }
    appendView(levelButton)

    //  Color gradient for title bar
    Application.later {
      self.grad.frame = self.div.bounds
      self.grad.colors = [UIColor(red: 0, green: 0.75, blue: 0, alpha: 1).cgColor,
                     UIColor(red: 0, green: 0.25, blue: 0, alpha: 1).cgColor]
      self.div.layer.insertSublayer(self.grad, at: 0)
    }
  }

  var title:String {
    get {
      return titleView.text
    }
    set {
      titleView.text = newValue
      titleView.fitTextToBounds()
      //  Set gradient frame in case device was rotated
      grad.frame = div.bounds
      //  Set top margins for os stuff
      let m = !Application.istablet && Application.isLandscape ? 0 : 10
      backButton.topMargin = m
      titleView.topMargin = m
      speakerButton.topMargin = m
      levelButton.topMargin = m
      layoutChildren()

      if (Application.app.canGoBack()) {
        backButton.show()
      } else {
        backButton.hide()
      }
      level = ""  // caller has to re-set level if desired
      speakerButton.hide()
      // check for audio file
      hasAudio = false
      let calls = TamUtils.calldoc.xpath("/calls/call[@title=\(title.quote())]")
      if (!calls.isEmpty) {
        if let audiofile = calls[0].attr("audio") {
          hasAudio = true
          speakerButton.show()
          speakerButton.clickAction {
            //  Strip off any extension
            let pathparts = (audiofile as NSString).pathComponents
            //  We can assume that the file has just one directory and then the filename
            let path = "files/" + pathparts[0]
            let filename = pathparts[1].split {
              $0 == "."
            }.map(String.init)[0]
            let filePath = Bundle.main.path(forResource: filename, ofType: "mp3", inDirectory: path)!
            self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
            self.audioPlayer?.play()
          }
        }
      }
    }
  }

  var level:String {
    get { return levelButton.text }
    set {
      levelButton.text = newValue
      if (newValue.isBlank) {
        levelButton.hide()
      } else {
        levelButton.show()
      }
      layoutChildren()
    }
  }

}
