//
//  CYLScenarioFeedback.swift
//  Example-Scenarios
//

import UIKit

extension UIViewController {

    /// A short confirmation: an alert that closes itself after a second, also announced to VoiceOver so a VoiceOver
    /// user hears it even if the alert closes before focus reaches it.
    func cyl_showFeedback(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        UIAccessibility.post(notification: .announcement, argument: message)
        // VoiceOver users get more time to hear the message.
        let delay: TimeInterval = UIAccessibility.isVoiceOverRunning ? 2.5 : 1
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak alert] in
            alert?.dismiss(animated: true)
        }
    }
}
