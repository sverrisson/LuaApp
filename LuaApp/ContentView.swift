//
//  ContentView.swift
//  LuaApp
//
//  Created by Hannes Sverrisson on 28/10/2020.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var engine = LuaEngine()
    
    var body: some View {
        Text(engine.resultString)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear() {
                engine.updateWithResult("a = 7 + 35", name: "a")
            }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
