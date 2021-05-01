//
//  PageTabView.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 4/4/21.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import SwiftUI

struct PageTabView: View {
    @Binding var selection: Int
    
    var body: some View {
        if #available(iOS 14.0, *) {
            TabView(selection: $selection){
                ForEach(tabs.indices, id: \.self) { index in
                    TabDetailsView(index: index)
                    //
                }
            }
            .tabViewStyle(PageTabViewStyle())
        } else {
            // Fallback on earlier versions
        }
        
    }
}

struct PageTabView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            if #available(iOS 14.0, *) {
                GradientView()
                PageTabView(selection: Binding.constant(0))

            } else {
                // Fallback on earlier versions
            }
        }
       
    }
}
