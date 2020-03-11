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
import WebKit

class WebView : View {

  private let mydiv = WKWebView()
  private var afterload:()->() = { }

  init(_ link:String) {
    super.init(mydiv)
    mydiv.translatesAutoresizingMaskIntoConstraints = false
    mydiv.navigationDelegate = self
    if (link.count > 0) {
      setSource(link)
    }
  }

  func setSource(_ link:String, afterload: @escaping ()->() = { }) {
    let path = "files"
    let filePath = Bundle.main.path(forResource: link, ofType: "html", inDirectory:path)!
    let htmlfile = try? String(contentsOfFile: filePath)
    let baseURL = URL(fileURLWithPath: filePath)
    self.afterload = afterload
    mydiv.loadHTMLString(htmlfile!, baseURL: baseURL)
  }

  func eval(_ script:String, _ code:@escaping (String)->()) {
    mydiv.evaluateJavaScript(script) { (resultq,errorq) in
      if let result = resultq {
        code("\(result)")
      }
    }
  }

}

extension WebView : WKNavigationDelegate {
  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    afterload()
  }
}
