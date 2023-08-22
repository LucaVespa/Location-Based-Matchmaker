//
//  PinView.swift
//  Location Matchmaker
//
//  Created by Owner on 8/15/23.
//

import SwiftUI

struct PinView: View {
    var body: some View {
        ZStack{
            Image(systemName: "mappin").resizable().scaledToFit().foregroundColor(.red).frame(width: 30, height: 30)
            /*Image(systemName: "triangle.fill").resizable().scaledToFit().foregroundColor(.red).offset(y: -20).rotationEffect(Angle(degrees: 180.0)).frame(width: 10, height: 10).padding(.bottom, 0)*/
        }
        
    }
}

struct PinView_Previews: PreviewProvider {
    static var previews: some View {
        PinView()
    }
}
