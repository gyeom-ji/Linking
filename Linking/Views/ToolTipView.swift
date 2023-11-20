//
//  ToolTipView.swift
//  Linking
//
//  Created by 윤겸지 on 2023/05/06.
//

import SwiftUI

public extension View {
    func tooltip(_ toolTip: String) -> some View {
        self.overlay(TooltipView(toolTip))
    }
}

private struct TooltipView: NSViewRepresentable {
    let toolTip: String
    
    init(_ toolTip: String) {
        self.toolTip = toolTip
    }

    func makeNSView(context: NSViewRepresentableContext<TooltipView>) -> NSView {
        NSView()
    }
    
    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<TooltipView>) {
        nsView.toolTip = self.toolTip
    }
}
