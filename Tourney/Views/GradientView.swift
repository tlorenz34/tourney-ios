//
//  GradientView.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 4/4/21.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
struct GradientView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [
        Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)),
        Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)),
        Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)),
            
        ]
        ), startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea()
    }
}

struct GradientView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            GradientView()
        } else {
            // Fallback on earlier versions
        }
    }
}
