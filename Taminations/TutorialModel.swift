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

class UIAlertControllerExtension : UIAlertController {
  override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.portrait
  }
  override var shouldAutorotate : Bool {
    return false
  }
}


class TutorialModel : PracticeModel {

  static let tutdata = [
    "Use your %1 finger on the %1 side of the screen. " +
      "Do not put your finger on the dancer. " +
      "Slide your finger forward to move the dancer forward. " +
      "Try to keep pace with the adjacent dancer.",

    "Use your %1 finger to follow the turning path." +
      "Try to keep pace with the adjacent dancer.",

    "Normally your dancer faces the direction you are moving. " +
      "But you can use your %2 finger to hold or change the facing direction. " +
      "Press and hold your %2 finger on the %2 side " +
      "of the screen.  This will keep your dancer facing forward. " +
      "Then use your %1 finger on the %1 side " +
      "of the screen to slide your dancer horizontally.",

    "Use your %2 finger to turn in place. " +
      "To U-Turn Left, make a 'C' movement with your %2 finger."
  ]

  private var tutnum = 0
  private var primaryName:String {
    return Setting("PrimaryControl").s == "Left" ? "Left" : "Right"
  }
  private var secondaryName:String {
    return Setting("PrimaryControl").s == "Left" ? "Right" : "Left"
  }

  override init(_ layout: PracticeLayout) {
    super.init(layout)
    layout.definitionButton.hide()
  }

  override func failure() {
    layout.continueButton.hide()
  }

  override func success() {
    layout.continueButton.show()
    if (tutnum + 1 >= TutorialModel.tutdata.count) {
      let alert = UIAlertControllerExtension(title: "Tutorial Complete", 
        message: "Congratulations!  You have successfully completed the tutorial.", 
        preferredStyle: .alert)
      let handler:(UIAlertAction)->Void = { _ in
        Application.app.goBack()
      }
      let ok = UIAlertAction(title: "Return", style: .default, handler: handler)
      alert.addAction(ok)
      let vc = UIApplication.shared.keyWindow!.rootViewController!
      vc.present(alert, animated: true)
      tutnum = 0
    }
  }

  override func nextAnimation(_ level: String) {
    if (level == "Continue") {
      tutnum += 1
    }
    if (tutnum >= TutorialModel.tutdata.count) {
      tutnum = 0
    }
    let tutdoc = TamUtils.getXMLAsset("src/tutorial")
    let gender = Setting("PracticeGender").s == "Girl" ? 2 : 1
    let tamlist = tutdoc.xpath("/tamination/tam")
    let tam = tamlist[tutnum]
    av.setAnimation(tam,intdan:gender,intrandom: false)
    Application.app.titleBar.title = tam.attr("title")!
    let instruction = TutorialModel.tutdata[tutnum]
      .replaceAll("%1",primaryName)
      .replaceAll("%2",secondaryName)
    let alert = UIAlertControllerExtension(title: "Tutorial \(tutnum+1)",
      message: instruction,
      preferredStyle: .alert)
    let handler:(UIAlertAction)->Void = { _ in
      self.av.doPlay()
    }
    let ok = UIAlertAction(title: "OK", style: .default, handler: handler)
    alert.addAction(ok)
    let vc = UIApplication.shared.keyWindow!.rootViewController!
    vc.present(alert, animated: true)
  }


}
