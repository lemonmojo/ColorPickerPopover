import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var testView: ColorDemoTestView!
}

extension AppDelegate: RAPopoverColorWellDelegate {
    func colorWell(_ colorWell: RAPopoverColorWell, didChangeColor color: NSColor) {
        testView.layer?.backgroundColor = color.cgColor
    }
}
