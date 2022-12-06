import Foundation

public struct ScrollView<Content: View>: View, Primitive {
    let content: VStack<Content>

    public init(@ViewBuilder _ content: () -> Content) {
        self.content = VStack(content: content())
    }

    static var size: Int? { 1 }

    func buildNode(_ node: Node) {
        node.addNode(at: 0, Node(nodeBuilder: content.nodeBuilder))
        let control = ScrollControl()
        control.contentControl = node.children[0].control(at: 0)
        control.addSubview(control.contentControl, at: 0)
        node.control = control
    }

    func updateNode(_ node: Node) {
        node.nodeBuilder = self
        node.children[0].update(using: content.nodeBuilder)
    }
}

private class ScrollControl: Control {
    var contentControl: Control!
    var contentOffset: Int = 0
    var contentSize: Size = .zero

    override func cell(at position: Position) -> Cell? {

        if position.column == layer.frame.size.width - 1 {
            switch position.line {
            case 0:
                if contentOffset > 0 {
                    return Cell(char: "Ʌ")
                }
            case layer.frame.size.height - 1:
                if contentSize.height > self.layer.frame.size.height {
                    return Cell(char: "V")
                }
            default:
                break
            }
        }

        return Cell(char: " ")
    }

    override func layout(size: Size) {
        super.layout(size: size)
        contentSize = contentControl.size(proposedSize: .zero)
        contentControl.layout(size: contentSize)
        contentControl.layer.frame.position.line = -contentOffset
    }

    override func scroll(to position: Position) {
        let destination = position.line - contentControl.layer.frame.position.line
        guard layer.frame.size.height > 0 else { return }
        if contentOffset > destination {
            contentOffset = destination
        } else if contentOffset < destination - layer.frame.size.height + 1 {
            contentOffset = destination - layer.frame.size.height + 1
        }
        // Here we would want to invalidate and redraw the ScrollControl if
        // a) we are at end of scrolling (to remove arrow down)
        // b) we just started scrolling (to add arrow up)
        // c) we are at start scrolling (to remove arrow up)
        // I don't know appropriate way to invalidate ourself...
    }
}
