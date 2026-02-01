//
//  ActivityView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//
import SwiftUI

struct ActivityView: View {
    var profile: Profile = Profile.sampleProfile
    
    var walkActivity: WalkActivity = WalkActivity(currentMinutes: 23, goalMinutes: 60)
    
    var meals: [Meal] = Meal.sampleMeals
    
    var vaccine : Vaccine = Vaccine.sampleVaccines
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators:false) {
                ZStack {
                    VStack(spacing: 20) {
                        
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text("Hello \(profile.dogName)")
                                    .font(.system(size: 16))
                                    .bold()
                                    .foregroundStyle(Color("baseRed"))
                                
                                Text("\(profile.breed). \(profile.gender), \(profile.age) years")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            
                            Circle()
                                .fill(.gray.opacity(0.2))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(profile.dogImage)
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(Circle())
                                        .frame(width: 64, height: 64)
                                )
                        }
                        .padding(.horizontal)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 34)
                                .fill(.gray.opacity(0.1))
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                            
                            HStack(spacing: 20) {
                                
                                CircularProgressView(progress: walkActivity.progress)
                                    .frame(width: 100, height: 100)
                                    .padding(.leading, 20)
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Walked")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(Color("baseRed"))
                                    
                                    Text("\(walkActivity.currentMinutes)/\(walkActivity.goalMinutes)min")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundStyle(.primary)
                                    
                                    Button {
                                        print("Start Walk tapped")
                                    } label: {
                                        Text("START")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(Color("baseRed"))
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .stroke(Color("baseRed"), lineWidth: 1.5)
                                            )
                                    }
                                    .padding(.top, 4)
                                }
                                Spacer()
                            }
                        }
                        .frame(height: 190)
                        .padding(.horizontal)
                        
                        //vaccine card
                        HStack(spacing:16) {
                            ZStack{
                                RoundedRectangle(cornerRadius:34)
                                    .fill(.gray.opacity(0.1))
                                    .frame(width: 175, height:190)
                                VStack(alignment: .leading){
                                    HStack{
                                        Text("Upcoming")
                                            .font(.system(size: 22,weight: .regular))
                                        Button{
                                            
                                        }label: {
                                            Circle()
                                                .fill(Color("baseRed").opacity(0.2))
                                                .frame(width:22,height:22)
                                                .overlay(
                                                    Image(systemName: "chevron.right")
                                                        .foregroundStyle(.black)
                                                        .font(.system(size: 12))
                                                )
                                        }
                                    }
                                    Image(systemName: "syringe")
                                        .foregroundStyle(.baseRed)
                                        .rotationEffect(.degrees(270))
                                        .font(.system(size: 65))
                                    Text(vaccine.name)
                                        .font(.system(size: 18,weight: .medium))
                                    Text("\(vaccine.daysLeft) days left")
                                        .font(.system(size: 12,weight:.semibold))
                                }
                                .frame(height: 175)
                            }
                            //Meals Card
                            MealsCardView()
                        }
                        
                        //alergies k liye
                        ZStack{
                            RoundedRectangle(cornerRadius: 23)
                                .fill(.gray.opacity(0.1))
                                .frame(width:370, height:95)
                        }
                        
                        //graph
                        ZStack{
                            RoundedRectangle(cornerRadius: 34)
                                .fill(.gray.opacity(0.1))
                                .frame(width:370, height:153)
                        }
                        
                        Spacer()
                    }
                    .padding(.top)
                }
            }
        }
    }
}

#Preview {
    ActivityView()
}
