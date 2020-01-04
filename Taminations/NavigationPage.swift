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

class NavigationPage : Page {

  var pages:[Page] = []
  private var currentPage:Page?
  //  The view holds just one child view at a time, which
  //  is the view of the selected page
  private var _view = StackLayout()
  override var view:View {
    get { return _view }
  }

  //  Finds the first page that can handle an Request
  //  and loads it into a Content
  override func doRequest(_ request: Request) -> Bool {
    //  First see if the currently displayed page can handle the Request
    let nextPageq = currentPage?.canDoAction(request.action) ?? false
      ? currentPage
      //  Nope, check all other pages to see who wants to handle it
      : pages.first { $0.canDoAction(request.action) }
    if let nextPage = nextPageq {

      //  Rotate as needed for this page
      AppDelegate.AppUtility.setOrientation(nextPage.orientation)

      nextPage.doRequest(request)
      //  Default is to only animate page changes
      //  If the page wants to animate itself it can do it
      //  when processing the request
      if (currentPage == nil || currentPage! !== nextPage) {
        Page.animate(currentPage, nextPage) {
          self._view.clear()
          self._view.appendView(nextPage.view)
        }
        self.currentPage = nextPage
      }
      return true
    }
    //  Could not find page the easy way, just push the request
    //  (don't think this ever happens)
    return false
  }

  override func canDoAction(_ action:Request.Action) -> Bool {
    return pages.contains { $0.canDoAction(action) }
  }

  override func sendMessage(_ message: Request) {
    currentPage?.sendMessage(message)
  }

}
