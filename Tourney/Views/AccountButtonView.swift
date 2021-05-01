//
//  AccountButtonView.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 4/4/21.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import SwiftUI

struct AccountButtonView: View {
    @Binding var isOnboardingViewShowing: Bool
    
    var body: some View {
        Button(action: {dismiss() }, label: {
            Text("Have an account? Log in")
                .foregroundColor(.black)
                .underline()
        })
    }
    
    func dismiss() {
        withAnimation{
            isOnboardingViewShowing.toggle()
        }
    }
}

struct AccountButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AccountButtonView(isOnboardingViewShowing: Binding.constant(true))
    }
}
