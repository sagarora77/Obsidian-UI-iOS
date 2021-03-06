//
//  NotificationBanner.swift
//  Alfredo
//
//  Created by Eric Kunz on 10/2/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

///This delegate responds to taps on the banner view.
public protocol NotificationBannerDelegate {

    /// Called when the banner is tapped
    func tapped(banner: NotificationBanner)

    /// Called when the banner begins to animage-in
    func willBeginDisplaying(banner: NotificationBanner)

    /// Called when the banner is done animating-in
    func didDisplay(banner: NotificationBanner)

    /// Called when the banner begins to animate-out
    func willEndDisplaying(banner: NotificationBanner)

    /// Called when the banner has fully animated-out
    func didEndDisplaying(banner: NotificationBanner)
}

/**
A view that drops-down from the top of a view controller.
Can be shown in any UIView or UINavigationController by calling
presentInView or presentInViewController.

If you would like to present this view over a UITableview it is recommened
that you present this in a UINavigationController that contains the table view.
Then set the top contentInset of the table to fit the height of the banner.

*/
public class NotificationBanner: FloatingView {

    // MARK: Public Properties

    /// The text of the banner.
    public var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }

    /// The font of the text.
    public var font: UIFont {
        get {
            return label.font
        }
        set {
            label.font = newValue
        }
    }

    /// The color of the text.
    public var textColor: UIColor {
        get {
            return label.textColor
        }
        set {
            label.textColor = newValue
        }
    }

    /// The duration of the move in and out animation
    public var animationDuration = 0.4

    /// The delegate responds to taps on the banner.
    public var delegate: NotificationBannerDelegate?

    /// The time that the banner is fully in view. Default is 3 seconds.
    public var displayTime = 3.0

    // MARK: Private Properties
    private var label = UILabel()

    // MARK: Initialization

    /// :nodoc:
    public init(message: String, color: UIColor = UIColor.darkGray(), textColor: UIColor = .white(), height: CGFloat = 35, duration: Double = 3.0) {
        super.init(frame: CGRect.zero)
        commonInit()
        configureBanner(color: color, textColor: textColor, message: message, duration: duration, height: height)
    }

    /// :nodoc:
    convenience public init() {
        self.init(frame: CGRect.zero)
        commonInit()
    }

    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    /// :nodoc:
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapRecognizer)

        addSubview(label)
        label.textAlignment = .center
    }

    // MARK: Presentation

    /**
    Presents the view ito a UINavigationController.

    - parameter navigationController: The navigationController to present into.

    */
    public func presentInNavigationController(navigationController: UINavigationController) {
        let view = navigationController.view
        let topBarHeight = navigationController.navigationBar.frame.height
        frame = CGRect(0, -topBarHeight, (view?.width)!, height)
        view?.insertSubview(self, belowSubview: navigationController.navigationBar)

        show(topOfView: UIApplication.shared().statusBarFrame.height + navigationController.navigationBar.frame.height, width: (view?.width)!, height: height + topBarHeight)
    }

    /**
    Presents the view ito a UINavigationController.

    - parameter navigationController: The navigationController to present into.
    - parameter originY: The Y compontent of the origin of the presented banner.

    */
    public func presentInNavigationController(navigationController: UINavigationController, originY: CGFloat) {
        let view = navigationController.view
        frame = CGRect(0, -originY, (view?.width)!, height)
        view?.insertSubview(self, belowSubview: navigationController.navigationBar)

        show(topOfView: originY, width: (view?.width)!, height: height + originY) // FIXME: These optionals
    }

    /**
    Presents the view ito a UIView.

    - parameter view: The view to present into.

    */
    public func presentInView(view: UIView) {
        frame = CGRect(0, -height, view.width, height)
        view.addSubview(self)

        show(topOfView: 0, width: view.width, height: height)
    }

    private func configureBanner(color: UIColor = UIColor.darkGray(), textColor: UIColor = UIColor.white(), message: String, duration: Double = 3.0, height: CGFloat = 35) {
        text = message
        backgroundColor = color
        self.textColor = textColor
        displayTime = duration
        frame.size.height = height
    }

    private func show(topOfView originY: CGFloat, width: CGFloat, height: CGFloat) {
        label.frame = bounds

        var visibleFrame = frame
        visibleFrame.origin.y = 0 + originY

        delegate?.willBeginDisplaying(banner: self)
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.frame = visibleFrame
            }) { (finished) -> Void in
                let _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.animateOutBanner), userInfo: nil, repeats: false)
        }
    }

    func animateOutBanner() {
        delegate?.willEndDisplaying(banner: self)

        var hiddenFrame = frame
        hiddenFrame.origin.y = -(frame.height + 100)

        UIView.animate(withDuration: self.animationDuration, delay: 0, options: .layoutSubviews, animations: { () -> Void in
            self.frame = hiddenFrame
            }, completion: { (finished) -> Void in
                self.delegate?.didEndDisplaying(banner: self)
                self.removeFromSuperview()
        })
    }

    // MARK: Action

    func handleTap() {
        delegate?.tapped(banner: self)
    }

}
