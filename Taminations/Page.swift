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

class Page {

  var view: View {
    get {
      fatalError("Subclasses need to override the view property.")
    }
  }

  //  Default orientation - portrait for phones, landscape for tablet
  var orientation: UIInterfaceOrientationMask {
    return Application.istablet ? .all : .portrait
  }

  static func oneAnimation(_ page:Page, _ alphaEndValue:Int, _ scaleEndValue:Int, after:@escaping ()->() = { }) {

    let alphaEnd = Setting("Transitions").s == "None" ? 1.cg : alphaEndValue.cg
    let scaleEnd = Setting("Transitions").s == "Fade and Zoom"
      //  iOS doesn't like to scale to 0, so instead use a small positive value
      ? scaleEndValue.cg + (1-scaleEndValue.cg) * 0.001.cg
      : 1.cg
    let alpha0 = 1 - alphaEnd
    let alpha1 = alphaEnd
    let scale0 = Setting("Transitions").s == "Fade and Zoom"
      ? CGAffineTransform(scaleX: 1-scaleEnd, y: 1-scaleEnd)
      : CGAffineTransform(scaleX: scaleEnd, y: scaleEnd)
    let scale1 = CGAffineTransform(scaleX: scaleEnd, y: scaleEnd)


    if (Setting("Transitions").s == "None") {
      page.view.div.transform = scale1
      page.view.div.alpha = alpha1
      Application.later {
        after()
        Application.app.sendMessage(Request.Action.TRANSITION_COMPLETE)
      }
    }
    else {  //  either Fade or Fade + Zoom
      page.view.div.transform = scale0
      page.view.div.alpha = alpha0
      UIView.animate(withDuration: 0.3, animations: {
        page.view.div.transform = scale1
        page.view.div.alpha = alpha1
      }, completion: { _ in
        after()
        Application.app.sendMessage(Request.Action.TRANSITION_COMPLETE)
      })
    }
  }

  //  Animate a transition between pages
  static func animate(_ currentPageOpt: Page?, _ nextPage: Page, _ code:@escaping ()->()) {
    if let currentPage = currentPageOpt {
      oneAnimation(currentPage,0,0) {
        code()
        oneAnimation(nextPage,1,1)
      }
    } else {
      code()
      oneAnimation(nextPage, 1, 1)
    }
  }

  //  Almost always a simple page handles just one request action
  //  So these are convenience methods for that case
  private var requestAction: Request.Action = Request.Action.NONE
  private var requestCode: (Request) -> () = { _ in }

  func onAction(_ action: Request.Action, _ code: @escaping (Request) -> ()) {
    requestAction = action
    requestCode = code
  }

  //  If it cannot handle the given request, it returns false
  //  Default is to handle the single action registered with onAction
  //  A page can override this method for more complex cases
  @discardableResult
  func doRequest(_ request: Request) -> Bool {
    if (request.action == requestAction) {
      requestCode(request)
      return true
    }
    return false
  }

  func doRequest(_ action: Request.Action, _ pairs: (String, String)...) {
    doRequest(Request(action, pairs))
  }
  func doRequest(_ action:Request.Action, _ from:Request) {
    doRequest(Request(action,from))
  }

  func canDoAction(_ action: Request.Action) -> Bool { return action == requestAction }

  //  Other requests are sent as "messages"
  //  A page can register to process a message with the onMessage function
  private var messageAction = Dictionary<Request.Action,(Request)->()>()
  func onMessage(_ message:Request.Action, code:@escaping (Request)->()) {
    messageAction[message] = code
  }

  //  Anybody can send a message to a page or the application
  func sendMessage(_ message:Request) {
    if let action = messageAction[message.action] {
      action(message)
    }
//    messageAction[message.action]?(message)
  }
  func sendMessage(_ message:Request.Action, _ params:(String,String)...) {
    sendMessage(Request(message,params))
  }

}