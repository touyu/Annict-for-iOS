//
//  ActivityReviewView.swift
//  Portannict
//
//  Created by Yuto Akiba on 2021/01/07.
//

import SwiftUI
import KingfisherSwiftUI

struct ActivityReviewView: View {
    let review: ReviewFragment

    @State var isPresented: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            KFImage(review.user.avatarUrl)
                .resizable()
                .clipShape(Circle())
                .foregroundColor(.gray)
                .frame(width: 40, height: 40, alignment: .leading)
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                    Text(review.user.name)
                        .font(.system(size: 14, weight: .bold, design: .default))
                    Text("@\(review.user.username)")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(review.createdAt.toDate()?.toRelative())
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                }
                if let state = review.ratingAnimationState {
                    RatingStateView(ratingState: state)
                }
                Text(review.body)
                    .font(.body)
                Button(action: {
                    isPresented = true
                }) {
                    QuoteWorkView(work: review.work.fragments.workFragment)
                        .frame(height: 80)
                        .cornerRadius(8)
                }
                .sheet(isPresented: $isPresented) {
                    WorkView(workID: review.work.fragments.workFragment.annictId)
                }
            }
        }
    }
}

struct ActivityReviewView_Previews: PreviewProvider {
    static var previews: some View {
        let review = ReviewFragment(id: "",
                               annictId: 0,
                               createdAt: "",
                               body: "面白い作品だった",
                               ratingAnimationState: RatingState.good,
                               user: .init(unsafeResultMap: UserFragment.dummy.resultMap),
                               work: .init(unsafeResultMap: WorkFragment.dummy.resultMap))
        ActivityReviewView(review: review)
            .previewLayout(.fixed(width: 375, height: 200))
    }
}