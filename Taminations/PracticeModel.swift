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

class PracticeModel {

  let layout:PracticeLayout
  var level:String = ""
  var link:String = ""
  var av:AnimationView

  init(_ layout:PracticeLayout) {
    self.layout = layout
    av = layout.animationView
  }

  func animationReady() {
    av.setSpeed(Setting("PracticeSpeed").s ?? "Slow")
    av.setGridVisibility(true)
    layout.resultsPanel.hide()
  }

  func animationDone() {
    layout.scoreNumbers.text =
      "\(av.score.Ceil.i) / \((av.movingBeats * 10).i)"
    let result = av.score / (av.movingBeats * 10)
    if (result >= 0.9) {
      success()
      layout.scoreText.text = "Excellent!"
    } else if (result >= 0.7) {
      success()
      layout.scoreText.text = "Very Good!"
    } else {
      failure()
      layout.scoreText.text = "Poor"
    }
    layout.resultsPanel.show()
    layout.animationView.invalidate()
  }

  //  For tutorial
  func failure() { }
  func success() { }

  func nextAnimation(_ level:String) {
    self.level = level
    let selector = LevelObject.find(level).selector
    let calls = TamUtils.calldoc.xpath(selector)
    let e = calls.randomElement()!
    //  Remember link for definition
    link = e.attr("link")!
    let tamdoc = TamUtils.getXMLAsset(link)
    let tams = tamdoc.xpath("/tamination/tam")
    //  For now, skip any "difficult" animations
      .filter { e2 in e2.attr("difficulty") != "3" }
    //  Skip any call with parens in the title - it could be a cross-reference
    //  to a concept call from a higher level
      .filter { e2 in !e2.attr("title")!.contains("(") }
    if (!tams.isEmpty) {
      let tam = tams.randomElement()!
      let gender = Setting("PracticeGender").s == "Boy" ? Gender.BOY : Gender.GIRL
      //  Normally select a random dancer
      var randomDancer = true
      //  But if the animations starts with "Heads" or "Sides"
      //  then select the first dancer.
      //  Otherwise the formation could rotate 90 degrees
      //  which would be confusing
      let title = tam.attr("title")!
      if (title.contains("Heads") || title.contains("Sides")) {
        randomDancer = false
      }
      av.setAnimation(tam, intdan: gender.rawValue, intrandom: randomDancer)
      Application.app.titleBar.title = tam.attr("title")!
    } else {
      nextAnimation(level)  // try again
    }

  }

}
