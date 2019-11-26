//
// Created by Bradley Christie on 2019-02-16.
// Copyright (c) 2019 bradchristie. All rights reserved.
//

import UIKit

class Application : Page {

  private static var _app:Application?
  static var app:Application { get { return _app! } }
  private static var mybounds:CGRect { return UIScreen.main.bounds }
  private static var myheight:CGFloat { return UIScreen.main.bounds.height }
  private static var mywidth:CGFloat { return UIScreen.main.bounds.width }
  static let istablet = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad

  static var isLandscape: Bool {  get { return mywidth > myheight } }
  static var isPortrait: Bool { get { return myheight > mywidth } }
  static var screenHeight: Int { get { return myheight.i } }
  static let isTouch: Bool = true
   var contentPage: Page?
  private var _view = View()
  override var view:View { get { return _view } }
  lazy var titleBar = TitleBar()
  var keyboardAdjustmentView = View()

  class LandscapePage : NavigationPage {
    override init() {
      super.init()
      pages += [FirstLandscapePage(),
                SecondLandscapePage(),
                SequencerPage(),
                StartPracticePage(),
                TutorialPage(),
                PracticePage(),
                DefinitionPage()  // only from practice page
      ]
    }
  }
  lazy var landscapePage = LandscapePage()
  class PortraitPage : NavigationPage {
    override init() {
      super.init()
      pages += [LevelPage(),
                AboutPage(),
                CallListPage(),
                AnimListPage(),
                AnimationPage(),
                SettingsPage(),
                DefinitionPage(),
                StartPracticePage(),
                TutorialPage(),
                PracticePage(),
                SequencerPage(),
                SequencerInstructionPage(),
                SequencerSettingsPage(),
                AbbreviationsPage(),
                SequencerReferencePage()
      ]
    }
  }
  lazy var portraitPage = PortraitPage()
  lazy var layout = LinearLayout(Application.mybounds,LinearLayout.Direction.VERTICAL)

  override init() {
    super.init()
    Application._app = self
  }

  @discardableResult
  func buildDisplay() -> View {
    //  Add the title bar
    layout.clear()
    titleBar.fillHorizontal()
    titleBar.weight = 1
    layout.appendView(titleBar)
    //  View to hold content
    contentPage = Application.istablet && Application.isLandscape ? landscapePage : portraitPage
    contentPage!.view.removeFromParent()
    contentPage!.view.fillHorizontal()
    contentPage!.view.weight = 9
    layout.appendView(contentPage!.view)
    keyboardAdjustmentView.weight = 0
    keyboardAdjustmentView.height = 0
    layout.appendView(keyboardAdjustmentView)
    return layout
  }

  @discardableResult
  override func doRequest(_ request: Request) -> Bool {
    return contentPage?.doRequest(request) ?? false
  }

  //  When we want to go to another page, we convert the request
  //  to a hash location and push it to a stack.
  //  All this is so "back" will go back to the previous page.
  //  Init the hash with STARTUP so we can go back to it
  private var hashes:[String] = ["\(Request(Request.Action.STARTUP))"]
  func sendRequest(_ request:Request) {
    //  If requesting a startup (logo was presses)
    //  then user wants to restart, clear out all old stuff
    if (request.action == Request.Action.STARTUP) {
      hashes.removeAll()
    }
    hashes.append("\(request)")
    Application.later {
      self.doRequest(request)
    }
  }
  func sendRequest(_ action:Request.Action, _ params:(String,String)...) {
    sendRequest(Request(action,params))
  }

  //  Update the current location like sendRequest but don't
  //  actually send a request
  func updateLocation(_ request:Request) {
    hashes.removeLast()
    hashes.append(request.s)
  }
  func updateLocation(_ request:Request.Action, _ params:(String,String)...) {
    updateLocation(Request(request,params))
  }

  //  Message is like a Request except it does not get saved
  //  in the location history and is not expected to
  //  directly trigger a page change
  override func sendMessage(_ message: Request) {
    Application.later {
      self.contentPage?.sendMessage(message)
    }
  }

  func canGoBack()->Bool {
    return hashes.count > 1
  }

  //  This restores the current location
  //  Needed to handle device rotation
  func goHere() {
    if (hashes.count > 0) {
      doRequest(Request(hashes.last!))
    }
  }

  func goBack() {
    //  The top hash is the current page
    //  So to go back, we have to pop that and then look at the next one
    if (canGoBack()) {
      hashes.remove(at: hashes.count-1)
      doRequest(Request(hashes[hashes.count-1]))
    }
  }

  class func later(code: @escaping ()->()) {
    DispatchQueue.main.async { code() }
  }

  //  Return time in milliseconds
  class func currentTime() ->  Int64 {
    return Int64(CFAbsoluteTimeGetCurrent() * 1000.0)
  }

}
