//
//  OnboardingView.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 4/4/21.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    @State private var selection = 0
    @Binding var isOnboardingViewShowing: Bool
    
    
    var body: some View {
        ZStack {
            if #available(iOS 14.0, *) {
                GradientView()
            } else {
                // Fallback on earlier versions
            }
            
            VStack{
                PageTabView(selection: $selection)
                previousNextButtonView(selection: $selection)
                AccountButtonView(isOnboardingViewShowing: $isOnboardingViewShowing)
              
            }
        }
        .transition(.move(edge: .bottom))
    
    }
    

}



struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isOnboardingViewShowing: Binding.constant(true))
        
    }
}




