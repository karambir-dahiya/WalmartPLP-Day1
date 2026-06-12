//
//  ContentView.swift
//  Product_Listing-Page(PLP)
//
//  Created by Siyaa Dahiya on 12/06/26.
//



import SwiftUI

struct ContentView: View {
    @ObservedObject var vm = GridViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVGrid(columns:
                                [GridItem(.flexible(minimum: 100, maximum: 200),alignment: .top),
                                 GridItem(.flexible(minimum: 100, maximum: 200), alignment: .top)]
                    ) {
                        ForEach(vm.feeds , id: \.self) { item in
                            VStack (alignment: .leading){
                                AsyncImage(url: URL(string: item.artworkUrl100))
                                    .scaledToFill()
                                    .cornerRadius(10)
                                Text("\(item.kind)")
                                    .font(.title2)
                                Text("\(item.name)")
                                    .font(.callout)
                                Text("\(item.releaseDate)")
                                    .font(.callout)
                            }
                        }
                        
                    }
                }
            }
            .padding()
        }.navigationTitle("Product Listing")
            .onAppear {
                vm.getData()
            }
    
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
    
}
