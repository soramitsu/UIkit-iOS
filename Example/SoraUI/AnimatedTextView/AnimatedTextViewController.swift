import UIKit
import SoraUI

final class AnimatedTextViewController: UIViewController {
    @IBOutlet private var nameField: AnimatedTextField!
    @IBOutlet private var networkField: AnimatedTextField!

    @IBAction public func actionDone() {
        nameField.resignFirstResponder()
        networkField.resignFirstResponder()
    }
}
