//
//  Preview.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/26.
//

import SwiftUI

struct Preview<V: View>: View {
    enum Device: String, CaseIterable{
        case iPhone12Mini = "iPhone 12 Mini"
        case iPadAir3 = "iPad Air (3rd generation)"
        
    }
    
    let source: V
    var devices: [Device] = [.iPhone12Mini, .iPadAir3]
    var displayDarkMode: Bool = true
    
    var body: some View {
        Group {
            ForEach(devices, id: \.self, content: {
                self.previewSource(device: $0)
            })
            if !devices.isEmpty && displayDarkMode {
                self.previewSource(device: devices[0])
                    .preferredColorScheme(.dark)
            }
            
        }
    }
    
    private func previewSource(device: Device) -> some View {
        source
            .previewDevice(PreviewDevice(rawValue: device.rawValue))
            .previewDisplayName(device.rawValue)
    }
}

struct Preview_Previews: PreviewProvider {
    static var previews: some View {
        Preview(source: Text("Hello, swiftUI"))
    }
}
