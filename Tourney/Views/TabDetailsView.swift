//
//  TabDetailsView.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 4/4/21.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import SwiftUI

struct TabDetailsView: View {
    let index: Int
    
    var body: some View {
        VStack {
            Image(tabs[index].image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250)
            
            Text(tabs[index].title)
                .font(.title)
                .bold()
                .foregroundColor(.black)
            
            Text(tabs[index].text)
                .padding()
                .foregroundColor(.black)
        }
        .foregroundColor(.white)
    }
}

struct TabDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            if #available(iOS 14.0, *) {
                GradientView()
                TabDetailsView(index: 0)
            } else {
                // Fallback on earlier versions
            }
            
        }
    }
}
