//
//  TallRightLayout.swift
//  Amethyst
//
//  Created by Ian Ynda-Hummel on 12/14/15.
//  Copyright © 2015 Ian Ynda-Hummel. All rights reserved.
//

import Silica

public class TallRightLayout: Layout {
    private class TallRightReflowOperation: ReflowOperation {
        fileprivate let layout: TallRightLayout

        fileprivate init(screen: NSScreen, windows: [SIWindow], layout: TallRightLayout, windowActivityCache: WindowActivityCache) {
            self.layout = layout
            super.init(screen: screen, windows: windows, windowActivityCache: windowActivityCache)
        }

        fileprivate override func main() {
            if windows.count == 0 {
                return
            }

            let mainPaneCount = min(windows.count, layout.mainPaneCount)
            let secondaryPaneCount = windows.count - mainPaneCount
            let hasSecondaryPane = secondaryPaneCount > 0

            let screenFrame = adjustedFrameForLayout(screen)

            let mainPaneWindowHeight = round(screenFrame.size.height / CGFloat(mainPaneCount))
            let secondaryPaneWindowHeight = hasSecondaryPane ? round(screenFrame.size.height / CGFloat(secondaryPaneCount)) : 0.0

            let mainPaneWindowWidth = round(screenFrame.size.width * (hasSecondaryPane ? CGFloat(layout.mainPaneRatio) : 1.0))
            let secondaryPaneWindowWidth = screenFrame.size.width - mainPaneWindowWidth

            let focusedWindow = SIWindow.focused()

            let frameAssignments = windows.reduce([]) { frameAssignments, window -> [FrameAssignment] in
                var assignments = frameAssignments
                var windowFrame = CGRect.zero

                if frameAssignments.count < mainPaneCount {
                    windowFrame.origin.x = screenFrame.origin.x + secondaryPaneWindowWidth
                    windowFrame.origin.y = screenFrame.origin.y + (mainPaneWindowHeight * CGFloat(frameAssignments.count))
                    windowFrame.size.width = mainPaneWindowWidth
                    windowFrame.size.height = mainPaneWindowHeight
                } else {
                    windowFrame.origin.x = screenFrame.origin.x
                    windowFrame.origin.y = screenFrame.maxY - (secondaryPaneWindowHeight * CGFloat(frameAssignments.count - mainPaneCount + 1))
                    windowFrame.size.width = secondaryPaneWindowWidth
                    windowFrame.size.height = secondaryPaneWindowHeight
                }

                let frameAssignment = FrameAssignment(frame: windowFrame, window: window, focused: window.isEqual(to: focusedWindow), screenFrame: screenFrame)

                assignments.append(frameAssignment)

                return assignments
            }

            if isCancelled {
                return
            }

            performFrameAssignments(frameAssignments)
        }
    }

    override public static var layoutName: String { return "Tall Right" }
    override public static var layoutKey: String { return "tall-right" }

    private var mainPaneCount: Int = 1
    private var mainPaneRatio: CGFloat = 0.5

    override public func reflowOperationForScreen(_ screen: NSScreen, withWindows windows: [SIWindow]) -> ReflowOperation {
        return TallRightReflowOperation(screen: screen, windows: windows, layout: self, windowActivityCache: windowActivityCache)
    }

    override public func expandMainPane() {
        mainPaneRatio = min(1, mainPaneRatio + UserConfiguration.shared.windowResizeStep())
    }

    override public func shrinkMainPane() {
        mainPaneRatio = max(0, mainPaneRatio - UserConfiguration.shared.windowResizeStep())
    }

    override public func increaseMainPaneCount() {
        mainPaneCount = mainPaneCount + 1
    }

    override public func decreaseMainPaneCount() {
        mainPaneCount = max(1, mainPaneCount - 1)
    }
}
