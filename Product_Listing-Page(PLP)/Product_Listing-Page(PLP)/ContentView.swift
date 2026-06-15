//
//  ContentView.swift
//  Product_Listing-Page(PLP)
//
//  Created by Siyaa Dahiya on 12/06/26.
//



import SwiftUI
import SwiftData


struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @StateObject private var vm = ProductViewModel()
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) { // Aligns the banner to the bottom edge
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(vm.products) { item in
                            VStack(alignment: .leading) {
                                CachedImageView(thumbnailData: item.thumbnailData, fallbackURLString: item.thumbnailURL)
                                    .scaledToFit()
                                Text(item.title)
                                    .font(.headline)
                            }
                            .onAppear {
                                Task {
                                    await vm.loadMoreIfNeeded(currentItem: item)
                                }
                            }
                        }
                    }
                    .padding()
                    .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search products")
                }
                .refreshable {
                    if networkMonitor.isConnected {
                        await vm.refreshData()
                    }
                }
                
                // Visual Offline Banner Component
                if !networkMonitor.isConnected {
                    VStack {
                        HStack(spacing: 8) {
                            Image(systemName: "wifi.slash")
                                .font(.subheadline)
                            Text("No Internet Connection — Showing Offline Cache")
                                .font(.footnote)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.95))
                        .cornerRadius(8)
                        .padding(.horizontal, 16)
                        .shadow(radius: 4)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 10)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: networkMonitor.isConnected)
            .navigationTitle("Product Listing")
            .onAppear(perform: {
                vm.setupContext(modelContext)
            })
            .task {
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
