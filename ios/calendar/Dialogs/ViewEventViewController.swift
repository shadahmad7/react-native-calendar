// calendar/Dialogs/ViewEventViewController.swift

import UIKit
import React

// Only for `openEventInCalendarAsync`. Subclassing UINavigationController provides a header for the modal window.
class ViewEventViewController: UINavigationController, UIAdaptivePresentationControllerDelegate {

    private let resolve: RCTPromiseResolveBlock
    private let reject: RCTPromiseRejectBlock
    private let onDismiss: () -> Void

    init(rootViewController: UIViewController,
         resolve: @escaping RCTPromiseResolveBlock,
         reject: @escaping RCTPromiseRejectBlock,
         onDismiss: @escaping () -> Void) {
        self.resolve = resolve
        self.reject = reject
        self.onDismiss = onDismiss
        super.init(rootViewController: rootViewController)
        self.presentationController?.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presentationController?.delegate = self
    }

    // MARK: - Delegate
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onDismiss()
        resolve(["action": ResponseAction.canceled.rawValue])
    }
}
