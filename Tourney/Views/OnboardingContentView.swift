//
//  OnboardingContentView.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 4/4/21.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
struct OnboardingContentView: View {
    
   // @State private var isOnboardingViewShowing = true
    @AppStorage("OnboardingView") var isOnboardingViewShowing = true
    
    var body: some View {
        Group{
            if isOnboardingViewShowing {
                OnboardingView(isOnboardingViewShowing: $isOnboardingViewShowing)
            } else {
                Text("Hello, world!")
                    .padding()
            }
        }
    }
}

struct OnboardingContentView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            OnboardingContentView()
        } else {
            // Fallback on earlier versions
        }
    }
}
