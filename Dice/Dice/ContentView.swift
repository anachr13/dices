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
                Text("\(number)")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.black)
            }
        }
    }
}

extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
} 
