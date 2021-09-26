import Cocoa

internal class RAColorPanelViewController: NSViewController {
    var colorPanel: NSColorPanel!
    
    override func loadView() {
        if NSColorPanel.sharedColorPanelExists && NSColorPanel.shared.isVisible {
            NSColorPanel.shared.orderOut(self)
        }
        
        colorPanel = NSColorPanel.shared
        colorPanel.orderOut(self)
        colorPanel.showsAlpha = true
        colorPanel.mode = .wheel
        
        view = colorPanel.contentView!
        
        if let swatch = locateColorSwatch() {
            swatch.perform(NSSelectorFromString("updateSwatch"))
        }
    }
}

private extension RAColorPanelViewController {
    func locateColorSwatch() -> NSView? {
        return findSwatchInSubviews(v: self.view)
    }
    
    func findSwatchInSubviews(v: NSView) -> NSView? {
        let classNameToLocate = "NSColorSwatch"
//        let classNameToLocate = "NSColorPickerWheelView"
        
        for subview in v.subviews {
            NSLog(subview.className)
            
            if subview.className == classNameToLocate {
                return subview
            } else if let foundView = findSwatchInSubviews(v: subview) {
                return foundView
            }
        }
        
        return nil
    }
}
