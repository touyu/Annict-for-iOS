//
//  ProfileView.swift
//  Portannict
//
//  Created by Yuto Akiba on 2020/07/11.
//

import SwiftUI
import KingfisherSwiftUI
import ComposableArchitecture

extension GetViewerQuery.Data.Viewer: Equatable { }

struct ProfileState: Equatable {
    var viewer: GetViewerQuery.Data.Viewer?
    var curerntIndex: Int = 0
    var isSettingPresented = false
    var settingState: SettingState?
}

enum ProfileAction: Equatable {
    case fetch
    case updateIndex(Int)
    case settingButtonTapped
    case setSettingSheet(isPresented: Bool)

    case setViewer(Result<GetViewerQuery.Data.Viewer, APIError>)

    case setting(SettingAction)
}

struct ProfileEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
}

let profileReducer = Reducer<ProfileState, ProfileAction, ProfileEnvironment>.combine(
    settingReducer
        .optional()
        .pullback(state: \.settingState,
                  action: /ProfileAction.setting,
                  environment: { _ in SettingEnvironment() }),
    Reducer { state, action, env in
        struct RequestId: Hashable {}

        switch action {
        case .fetch:
            return APIClient.shared.fetchEffect(query: GetViewerQuery())
                .compactMap { $0.viewer }
                .receive(on: env.mainQueue)
                .catchToEffect()
                .map(ProfileAction.setViewer)
                .cancellable(id: RequestId())
        case .updateIndex(let index):
            state.curerntIndex = index
            return .none
        case .settingButtonTapped:
            return Effect(value: .setSettingSheet(isPresented: true))
        case .setSettingSheet(isPresented: true):
            state.isSettingPresented = true
            state.settingState = SettingState()
            return .none
        case .setSettingSheet(isPresented: false):
            state.isSettingPresented = false
            state.settingState = nil
            return .none
        case .setViewer(.success(let viewer)):
            state.viewer = viewer
            return .none
        case .setViewer(.failure(let error)):
            return .none
        case .setting(let settingActiion):
            switch settingActiion {
            case .logout:
                return Effect(value: .setSettingSheet(isPresented: false))
            }
        }
    }
)

struct ProfileView: View {
    let store: Store<ProfileState, ProfileAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    if let viewer = viewStore.viewer {
                        ProfileHeaderView(store: store)
                            .padding(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                        VStack(alignment: .leading, spacing: 24) {
                            Picker("", selection: viewStore.binding(
                                    get: \.curerntIndex,
                                    send: ProfileAction.updateIndex)
                            ) {
                                Text("ライブラリ")
                                    .tag(0)
                                Text("アクティビティ")
                                    .tag(1)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                            switch viewStore.curerntIndex {
                            case 0:
                                libraryView(viewer: viewer)
                            default:
                                Text("アクティビティ")
                            }
                        }
                        .padding(.init(top: 20, leading: 0, bottom: 20, trailing: 0))
                    } else {
                        Text("Loading")
                    }
                }
            }
            .onAppear {
                viewStore.send(.fetch)
            }
            .sheet(isPresented: viewStore.binding(
                get: \.isSettingPresented,
                send: ProfileAction.setSettingSheet(isPresented:)
            )) {
                IfLetStore(
                    store.scope(state: \.settingState,
                                action: ProfileAction.setting),
                    then: SettingView.init(store:)
                )
            }
        }
    }

    func libraryView(viewer: GetViewerQuery.Data.Viewer) -> some View {
        Group {
            LibraryWorksView(status: .watching, count: viewer.watchingCount)
            LibraryWorksView(status: .wannaWatch, count: viewer.wannaWatchCount)
            LibraryWorksView(status: .watched, count: viewer.watchedCount)
            LibraryWorksView(status: .onHold, count: viewer.onHoldCount)
            LibraryWorksView(status: .stopWatching, count: viewer.stopWatchingCount)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(store: Store(initialState: ProfileState(viewer: .dummy),
                                 reducer: profileReducer,
                                 environment: ProfileEnvironment(
                                    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                                 ))
        )

        ProfileView(store: Store(initialState: ProfileState(),
                                 reducer: profileReducer,
                                 environment: ProfileEnvironment(
                                    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                                 ))
        )
    }
}

extension GetViewerQuery.Data.Viewer {
    static var dummy: Self {
        GetViewerQuery.Data.Viewer(id: "",
                                   annictId: 0,
                                   name: "touyu",
                                   username: "touyu",
                                   avatarUrl: "https://api-assets.annict.com/shrine/profile/5482/image/master-70884f30052922f4f758e6eb69dc6985.jpg",
                                   description: "「Portannict」というAnnictのクライアントアプリ作ってます。",
                                   wannaWatchCount: 20,
                                   watchingCount: 120,
                                   watchedCount: 420,
                                   onHoldCount: 10,
                                   stopWatchingCount: 4)
    }
}
