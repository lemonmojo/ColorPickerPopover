import Cocoa

class ColorDemoTestView: NSView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        wantsLayer = true
        
        guard let layer = layer else {
            return
        }
        
        layer.cornerRadius = frame.size.width / 2.0
        layer.backgroundColor = NSColor.blue.cgColor
    }
}
