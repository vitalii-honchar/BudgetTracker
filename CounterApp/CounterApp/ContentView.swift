import SwiftUI

struct ContentView: View {
    @State private var counter = 0

    var body: some View {
        VStack(spacing: 30) {
            Text("Counter")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("\(counter)")
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(.blue)

            Button(action: {
                counter += 1
            }) {
                Text("Increment")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
