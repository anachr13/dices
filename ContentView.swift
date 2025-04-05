import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var viewModel = DiceViewModel()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                HStack(spacing: 20) {
                    DiceView(number: viewModel.leftDiceNumber, isRolling: viewModel.isRolling)
                    DiceView(number: viewModel.rightDiceNumber, isRolling: viewModel.isRolling)
                }
                
                if !viewModel.isRolling {
                    Button(action: {
                        viewModel.rollDice()
                    }) {
                        Text("Roll Dice")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gold)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
}

struct DiceView: View {
    let number: Int
    let isRolling: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .frame(width: 100, height: 100)
                .shadow(color: .gold.opacity(0.5), radius: 5, x: 0, y: 0)
            
            if !isRolling {
                DiceDots(number: number)
            }
        }
    }
}

struct DiceDots: View {
    let number: Int
    
    var body: some View {
        GeometryReader { geometry in
            let dotSize: CGFloat = 15
            let spacing: CGFloat = 10
            let padding: CGFloat = 20
            
            ZStack {
                // Center dot for odd numbers
                if number % 2 == 1 {
                    Circle()
                        .fill(Color.black)
                        .frame(width: dotSize, height: dotSize)
                }
                
                // Top-left and bottom-right dots
                if number >= 2 {
                    Circle()
                        .fill(Color.black)
                        .frame(width: dotSize, height: dotSize)
                        .position(x: padding, y: padding)
                    
                    Circle()
                        .fill(Color.black)
                        .frame(width: dotSize, height: dotSize)
                        .position(x: geometry.size.width - padding, y: geometry.size.height - padding)
                }
                
                // Top-right and bottom-left dots
                if number >= 4 {
                    Circle()
                        .fill(Color.black)
                        .frame(width: dotSize, height: dotSize)
                        .position(x: geometry.size.width - padding, y: padding)
                    
                    Circle()
                        .fill(Color.black)
                        .frame(width: dotSize, height: dotSize)
                        .position(x: padding, y: geometry.size.height - padding)
                }
                
                // Middle-left and middle-right dots for 6
                if number == 6 {
                    Circle()
                        .fill(Color.black)
                        .frame(width: dotSize, height: dotSize)
                        .position(x: padding, y: geometry.size.height / 2)
                    
                    Circle()
                        .fill(Color.black)
                        .frame(width: dotSize, height: dotSize)
                        .position(x: geometry.size.width - padding, y: geometry.size.height / 2)
                }
            }
        }
    }
}

extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
} 