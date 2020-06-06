//
// Created by Bradley Christie on 2019-02-15.
// Copyright (c) 2019 . All rights reserved.
//

import UIKit

extension Int {
  var dip:Int { get { (self.d*View.scale).i } }
  var pp:Int { get { (self*Application.screenHeight)/1000 } }
  var sp:Int { get { (self.pp.cg
    * (Setting("Dynamic Type").b ?? false 
    ? UIFont.preferredFont(forTextStyle: .body).pointSize / UIFont.labelFontSize : 1)).i  } }
}

class Align {
  static let None = 0
  static let Top = 1
  static let Bottom = 2
  static let Left = 4
  static let Right = 8
  static let Center = 16  // vertical
  static let Middle = 32  // horizontal
}

class View : NSObject {

  let div:UIView
  var parent:ViewGroup?
  static let scale:Double = Application.screenHeight.d / 1000.0
  var rightSwiper:UISwipeGestureRecognizer?
  var leftSwiper:UISwipeGestureRecognizer?

  //  Classes to put a border on
  //  one side of a layer
  class BorderLayer : CALayer {
    override init() {
      super.init()
      //  Need to set bounds to non-zero size
      //  or layer will be ignored on layout
      bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
    }
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    override init(layer: Any) {  // required by iOS
      super.init(layer:layer)
    }
  }

  class TopBorder : BorderLayer {
    override func layoutSublayers() {
      frame = CGRect(x: 0, y: 0, width: superlayer!.frame.width, height: borderWidth)
    }
  }
  class BottomBorder : BorderLayer {
    override func layoutSublayers() {
      frame = CGRect(x: 0, y: superlayer!.frame.height-1, width: superlayer!.frame.width, height: 1)
    }
  }
  class LeftBorder : BorderLayer {
    override func layoutSublayers() {
      frame = CGRect(x: 0, y: 0, width: 1, height: superlayer!.frame.height)
    }
  }
  class RightBorder : BorderLayer {
    override func layoutSublayers() {
      frame = CGRect(x: superlayer!.frame.width-1, y: 0, width: 1, height: superlayer!.frame.height)
    }
  }
  var topBorderLayer : TopBorder? = nil
  var bottomBorderLayer : BottomBorder? = nil
  var leftBorderLayer : LeftBorder? = nil
  var rightBorderLayer : RightBorder? = nil

  init(_ div:UIView = UIView()) {
    self.div = div
    div.translatesAutoresizingMaskIntoConstraints = false
    div.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }

  //  Colors
  var backgroundColor:UIColor {
    get { div.backgroundColor ?? UIColor.black }
    set(value) { div.backgroundColor = value }
  }
  var textColor:UIColor = UIColor.black
  var opacity:Double {
    get { div.alpha.d }
    set(value) { div.alpha = value.cg }
  }

  //  Only gradients used are top to bottom
  func linearGradient(top:UIColor, bottom:UIColor) { /* TODO */ }

  //  Borders
  var topBorder:Int {
    get { topBorderLayer?.borderWidth.i ?? 0 }
    set {
      if (topBorderLayer == nil) {
        topBorderLayer = TopBorder()
        div.layer.addSublayer(topBorderLayer!)
      }
      topBorderLayer?.borderWidth = newValue.cg
      topBorderLayer?.layoutSublayers()
    }
  }
  var bottomBorder:Int {
    get { bottomBorderLayer?.borderWidth.i ?? 0 }
    set {
      if (bottomBorderLayer == nil) {
        bottomBorderLayer = BottomBorder()
        div.layer.addSublayer(bottomBorderLayer!)
      }
      bottomBorderLayer?.borderWidth = newValue.cg
    }
  }
  var leftBorder:Int {
    get { leftBorderLayer?.borderWidth.i ?? 0 }
    set {
      if (leftBorderLayer == nil) {
        leftBorderLayer = LeftBorder()
        div.layer.addSublayer(leftBorderLayer!)
      }
      leftBorderLayer?.borderWidth = newValue.cg
    }
  }
  var rightBorder:Int {
    get { rightBorderLayer?.borderWidth.i ?? 0 }
    set {
      if (rightBorderLayer == nil) {
        rightBorderLayer = RightBorder()
        div.layer.addSublayer(rightBorderLayer!)
      }
      rightBorderLayer?.borderWidth = newValue.cg
    }
  }
  var border: Int {
    get { 0 }
    set {
      topBorder = newValue
      bottomBorder = newValue
      leftBorder = newValue
      rightBorder = newValue
    }
  }
  var borderColor:UIColor {
    get { UIColor(cgColor:div.layer.borderColor ?? UIColor.black.cgColor) }
    set { div.layer.borderColor = newValue.cgColor }
  }

  //  Padding - not necessary?

  //  Margins
  private var _topMargin = 0
  private var _bottomMargin = 0
  private var _leftMargin = 0
  private var _rightMargin = 0
  var topMargin:Int {
    get { _topMargin }
    set(value) { _topMargin = value; parent?.layoutChildren() }
  }
  var bottomMargin:Int {
    get { _bottomMargin }
    set(value) { _bottomMargin = value; parent?.layoutChildren() }
  }
  var leftMargin:Int {
    get { _leftMargin }
    set(value) { _leftMargin = value; parent?.layoutChildren() }
  }
  var rightMargin:Int {
    get { _rightMargin }
    set(value) {
      _rightMargin = value;
      parent?.layoutChildren()
    }
  }
  var margins:Int {
    get { 0 }
    set {
      bottomMargin = newValue
      topMargin = newValue
      leftMargin = newValue
      rightMargin = newValue
    }
  }

  //  Layout params
  var width:Int {
    get {
      //  If current size is 0, then ask the view to size itself
      if (div.bounds.width == 0) {
        div.sizeToFit()
      }
      return div.bounds.width.i
    }
    set(value) {
      var mybounds = div.bounds
      mybounds.size.width = value.cg
      div.bounds = mybounds
    }
  }
  var height:Int {
    get {
      if (div.bounds.height == 0) {
        div.sizeToFit()
      }
      return div.bounds.height.i
    }
    set(value) {
      var mybounds = div.bounds
      mybounds.size.height = value.cg
      div.bounds = mybounds
    }
  }

  private var _weight = 0
  var weight:Int {
    get { _weight }
    set(value) { _weight = value; parent?.layoutChildren() }
  }
  @discardableResult
  func weight(_ value:Int) -> View {
    weight = value
    return self
  }

  var align:Int = Align.None
  @discardableResult
  func alignLeft() -> View {
    if (align & Align.Left == 0) {
      align |= Align.Left
      parent?.layoutChildren()
    }
    return self
  }
  @discardableResult
  func alignRight() -> View {
    if (align & Align.Right == 0) {
      align |= Align.Right
      parent?.layoutChildren()
    }
    return self
  }
  @discardableResult
  func fillHorizontal() -> View {
    if (align & (Align.Left | Align.Right) != (Align.Left | Align.Right)) {
      align |= Align.Left | Align.Right
      parent?.layoutChildren()
    }
    return self
  }
  @discardableResult
  func alignTop() -> View {
    if (align & Align.Top == 0) {
      align |= Align.Top
      parent?.layoutChildren()
    }
    return self
  }
  @discardableResult
  func alignBottom() -> View {
    if (align & Align.Bottom == 0) {
      align |= Align.Bottom
      parent?.layoutChildren()
    }
    return self
  }
  @discardableResult
  func fillVertical() -> View {
    if (align & (Align.Top | Align.Bottom) != (Align.Top | Align.Bottom)) {
      align |= Align.Top | Align.Bottom
      parent?.layoutChildren()
    }
    return self
  }
  @discardableResult
  func fillParent() -> View {
    fillHorizontal()
    fillVertical()
    return self
  }
  var isScrollable = false  // Instead use one of the scrolling views
  func removeFromParent() {
    parent?.removeView(self)
  }

  //  Align a (single) view in the vertical center of its parent
  @discardableResult
  func alignCenter() -> View {
    if (align & Align.Center == 0) {
      align |= Align.Center
      parent?.layoutChildren()
    }
    return self
  }
  //  Align a (single) view in the horizontal middle of its parent
  @discardableResult
  func alignMiddle() -> View {
    if (align & Align.Middle == 0) {
      align |= Align.Middle
      parent?.layoutChildren()
    }
    return self
  }

  enum SwipeDirection {
    case UP
    case DOWN
    case LEFT
    case RIGHT
  }

  //  Actions
  //  All actions and their code are declared here, although
  //  most are only applicable to inherited classes
  var clickCode:()->() = { }
  var touchDownCode:(UITouch,Int,Int)->() = { _,_,_ in }
  var touchMoveCode:(UITouch,Int,Int)->() = { _,_,_ in }
  var touchUpCode:(UITouch,Int,Int)->() = { _,_,_ in }
  func clickAction(code: @escaping ()->()) { clickCode = code}
  func wheelAction(code: @escaping (Int)->() ) { }
  func touchDownAction(code: @escaping (UITouch,Int,Int)->()) { touchDownCode = code }
  func touchMoveAction(code: @escaping (UITouch,Int,Int)->()) { touchMoveCode = code }
  func touchUpAction(code: @escaping (UITouch,Int,Int)->()) { touchUpCode = code }
  func keyDownAction(code: @escaping (Int)->()) { }
  func keyUpAction(code: @escaping (Int)->()) { }
  func displayAction(code: @escaping ()->()) { }
  private var longPressCode:(Int,Int)->() = { _,_ in }
  @objc private func longPress(_ sender:UILongPressGestureRecognizer) {
    if (sender.state == UIGestureRecognizer.State.began) {
      let pt = sender.location(in: div)
      longPressCode(pt.x.i, pt.y.i)
    }
  }
  func longPressAction(_ code: @escaping (Int,Int)->()) {
    longPressCode = code
    div.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
      action: #selector(View.longPress(_:))))
  }


  //  Focus, Hide and Show
  func focus() {
    div.becomeFirstResponder()
  }
  func blur() {
    div.resignFirstResponder()
  }

  func invalidate() {
    div.setNeedsDisplay()
  }

  func layoutChildren() {
    NSLayoutConstraint.deactivate(div.constraints)
  }

  //  The UIView.isHidden flag only make the view transparent
  //  but does not collapse it
  func hide() {
    if (!div.isHidden) {
      div.isHidden = true
      parent?.layoutChildren()
    }
  }
  func show() {
    if (div.isHidden) {
      div.isHidden = false
   //   parent?.layoutChildren()
      //  TODO fix this nasty hack
      //  needed to get previously hidden view to show
      Application.later {
        self.parent?.layoutChildren()
      }
    }
  }

  //  Scroll, Swipe
  func scrollToBottom() { }
  var swipeCode:(SwipeDirection)->() = { _ in }
  func swipeAction(code: @escaping (SwipeDirection)->()) {
    rightSwiper = UISwipeGestureRecognizer()
    rightSwiper!.direction = .right
    rightSwiper!.addTarget(self, action: #selector(View.rightSwipe))
    div.addGestureRecognizer(rightSwiper!)
    leftSwiper = UISwipeGestureRecognizer()
    leftSwiper!.direction = .left
    leftSwiper!.addTarget(self, action: #selector(View.leftSwipe))
    div.addGestureRecognizer(leftSwiper!)
    swipeCode = code
  }
  @objc func rightSwipe() {
    swipeCode(.RIGHT)
  }
  @objc func leftSwipe() {
    swipeCode(.LEFT)
  }

}
