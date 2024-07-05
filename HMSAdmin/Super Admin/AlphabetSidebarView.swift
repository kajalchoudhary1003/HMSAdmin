import SwiftUI

struct AlphabetSidebarView: View {
    var listView: AnyView
    var lookup: (String) -> Int?
    let alphabet: [String] = {
        (65...90).map { String(UnicodeScalar($0)!) }
    }()
    
    @GestureState private var dragLocation: CGPoint = .zero
    
    var body: some View {
        VStack {
            ForEach(alphabet, id: \.self) { letter in
                SectionIndexTitle(letter: letter)
                    .background(dragObserver(letter: letter))
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .updating($dragLocation) { value, state, _ in
                    state = value.location
                }
        )
    }
    
    @ViewBuilder
    func dragObserver(letter: String) -> some View {
        GeometryReader { geometry in
            Color.clear
                .onAppear {
                    print("Sidebar view appeared")
                }
                .onTapGesture {
                    print("Tapped on sidebar")
                }
                .onLongPressGesture {
                    print("Long pressed on sidebar")
                }
        }
    }
}

struct SectionIndexTitle: View {
    let letter: String
    
    var body: some View {
        Text(letter)
            .foregroundColor(.blue)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

