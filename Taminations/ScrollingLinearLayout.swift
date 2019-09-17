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

class ScrollingLinearLayout : ViewGroup {

  //  Use a scroll view with a fixed horizontal size that scrolls vertically
  //  Wrap the scroller in a view for setting content constraints
  let mydiv = UIView()
  let scrolldiv = UIScrollView()
  let content = LinearLayout(.VERTICAL)
  var items:[View] { return content.children }

  init() {
    super.init(mydiv)

    //  Scroller fills its container view
    let scroller = ViewGroup(scrolldiv)
    super.appendView(scroller)
    alignEdge(scroller,.top,self,.top)
    alignEdge(scroller,.bottom,self,.bottom)
    alignEdge(scroller,.left,self,.left)
    alignEdge(scroller,.right,self,.right)

    //  Following is the magic to get the scroll view
    //  to fits its contents horizontally and scroll vertically
    //  Content fits scroller container horizontally
    scroller.appendView(content)
    alignEdge(content,.left,self,.left)
    alignEdge(content,.right,self,.right)
    //  Set content to fit scroller vertically
    alignEdge(content, .top, scroller, .top)
    alignEdge(content,.bottom,scroller,.bottom)
  }

  @discardableResult
  override func appendView(_ child: View) -> View {
    return content.appendView(child)
  }

  override func removeView(_ child: View) {
    content.removeView(child)
  }

  override func clear() {
    content.clear()
  }

  override func layoutChildren() {
    content.layoutChildren()
  }

  func scrollToItem(_ item:Int) {
    //  Unfortunately does not work for me   scrolldiv.scrollRectToVisible(content.children[item].div.frame, animated: true)
    //  So instead compute where to scroll
    let ity = content.children[item].div.frame.origin.y
    let ith = content.children[item].div.frame.size.height
    if (scrolldiv.contentOffset.y > ity) {
      //  Content is scrolled down too far
      scrolldiv.setContentOffset(CGPoint(x: 0, y: ity),animated:true)
    } else if (scrolldiv.contentOffset.y + scrolldiv.bounds.size.height < ity + ith) {
      //  Content needs to scroll down
      scrolldiv.setContentOffset(CGPoint(x: 0, y: ity + ith - scrolldiv.bounds.size.height),animated:true)
    }
  }


}
