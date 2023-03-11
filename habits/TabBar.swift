//
//  TabBar.swift
//  habits
//
//  Created by Louis AB on 09/03/2023.
//

import SwiftUI

extension Animation {
    static let tabSelection = Animation.spring(response: 0.3, dampingFraction: 0.7)
}

struct TabBar: View {
    @State var color: Color = .init(.purple)
    @State var selectedX: CGFloat = 0
    @State var x: [CGFloat] = [0, 0, 0, 0]

    @EnvironmentObject var model: Model
    @AppStorage("selectedTab") var selectedTab: Tab = .home

    var body: some View {
        GeometryReader { proxy in
            let hasHomeIndicator = proxy.safeAreaInsets.bottom > 0

            HStack {
                content
            }
            .padding(.bottom, hasHomeIndicator ? 16 : 0)
            .frame(maxWidth: .infinity, maxHeight: hasHomeIndicator ? 88 : 49)
            .background(.ultraThinMaterial)
            .background(
                Circle()
                    .fill(color)
                    .offset(x: selectedX, y: -10)
                    .frame(width: 88)
                    .frame(maxWidth: .infinity, alignment: .leading)
            )
            .overlay(
                Rectangle()
                    .frame(width: 28, height: 5)
                    .cornerRadius(3)
                    .frame(width: 88)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .offset(x: selectedX)
                    .blendMode(.overlay)
            )
            .backgroundStyle(cornerRadius: hasHomeIndicator ? 34 : 0)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
            .offset(y: model.showTab ? 0 : 200)
            .accessibility(hidden: !model.showTab)
        }
    }

    var content: some View {
        ForEach(Array(tabItems.enumerated()), id: \.offset) { index, tab in
            if index == 0 { Spacer() }

            Button {
                selectedTab = tab.selection
                withAnimation(.tabSelection) {
                    selectedX = x[index]
                    color = tab.color
                }
            } label: {
                VStack(spacing: 0) {
                    Image(systemName: tab.icon)
                        .symbolVariant(.fill)
                        .font(.system(size: 17, weight: .bold))
                        .frame(width: 44, height: 29)
                    Text(tab.name).font(.caption2)
                        .frame(width: 88)
                        .lineLimit(1)
                }
                .overlay(
                    GeometryReader { proxy in
                        let offset = proxy.frame(in: .global).minX
                        Color.clear
                            .preference(key: TabPreferenceKey.self, value: offset)
                            .onPreferenceChange(TabPreferenceKey.self) { value in
                                x[index] = value
                                if selectedTab == tab.selection {
                                    selectedX = x[index]
                                }
                            }
                    }
                )
            }
            .frame(width: 44)
            .foregroundColor(selectedTab == tab.selection ? .primary : .secondary)
            .blendMode(selectedTab == tab.selection ? .overlay : .normal)

            Spacer()
        }
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar()
            .environmentObject(Model())
    }
}
