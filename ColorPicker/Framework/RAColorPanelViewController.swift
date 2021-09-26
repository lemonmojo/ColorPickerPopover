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
        
        if let toolbar = colorPanel.toolbar {
            NSLog("%i", toolbar.items.count)
            
            let item = toolbar.items[1]
            
            if let target = item.target {
                if let action = item.action {
                    let _ = target.perform(action, with: item)
                }
            }
        }
        
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
        
        for subview in v.subviews {
            if subview.className == classNameToLocate {
                return subview
            } else if let foundView = findSwatchInSubviews(v: subview) {
                return foundView
            }
        }
        
        return nil
    }
}
