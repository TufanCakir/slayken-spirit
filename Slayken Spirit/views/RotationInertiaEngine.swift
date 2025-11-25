import Foundation
import QuartzCore

final class RotationInertiaEngine {
    private var displayLink: CADisplayLink?
    var onUpdate: (() -> Void)?

    func start() {
        stop()
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .default)
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick() {
        onUpdate?()
    }

    deinit { stop() }
}
