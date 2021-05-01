//
//  previousNextButtonView.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 4/4/21.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import SwiftUI

struct previousNextButtonView: View {
    @Binding var selection: Int
    let buttons = ["Previous", "Next"]
    let previousButton = ["Previous"]
    let nextButton = ["Next"]
  
    @State var shouldHide = false
    
    
    var body: some View {
        HStack{
            if selection != 0{
                ForEach(buttons, id: \.self) {buttonLabel in
                Button(action: { buttonAction(buttonLabel)},
                       label: {
                        Text(buttonLabel)
                        .fontWeight(.heavy)
                        .padding()
                        .frame(width: 150, height: 44)
                        .background(Color.black.opacity(0.27))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                })
                    
            }
                
        }
            if selection == 0{
                ForEach(nextButton, id: \.self) {buttonLabel in
                Button(action: { buttonAction(buttonLabel)},
                       label: {
                        Text(buttonLabel)
                        .fontWeight(.heavy)
                        .padding()
                        .frame(width: 150, height: 44)
                        .background(Color.black.opacity(0.27))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                })
                    
            }
                
            }
        }
        .foregroundColor(.white)
        .padding()
    }
        
        
        
    func buttonAction(_ buttonLabel: String) {
        withAnimation{
            if buttonLabel == "Previous" && selection > 0 {
                selection -= 1
            } else if buttonLabel == "Next" && selection < tabs.count - 1{
                selection += 1
            }
            
    }

}
    


struct previousNextButtonView_Previews: PreviewProvider {
    static var previews: some View {
        previousNextButtonView(selection: Binding.constant(0))
    }
}
}

