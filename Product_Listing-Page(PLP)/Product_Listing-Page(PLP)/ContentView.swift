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
                                 GridItem(.flexible(minimum: 100, maximum: 200), alignment: .top),
                                 GridItem(.flexible(minimum: 100, maximum: 200), alignment: .top)]
                    ) {
                        ForEach(vm.products , id: \.self) { item in
                            VStack (alignment: .leading){
                                CachedImageView(urlString: item.thumbnail)
                                    .frame(height: 120)
                                Text("\(item.title)")
                                    .font(.default)
                                Text("\(item.description)")
                                    .font(.caption2)
                                    .lineLimit(3)
                                Spacer()
                            }
                            .onAppear {
                                Task {
                                    await vm.loadMoreIfNeeded(currentItem: item)
                                }
                            }
                        }
                        
                    }
                }
                .refreshable {
                    await vm.refreshData()
                }
            }
            .padding()
        }.navigationTitle("Product Listing")
            .task {
                if vm.products.isEmpty {
                    
                    await vm.getData()
                    
                }
            }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
    
}
