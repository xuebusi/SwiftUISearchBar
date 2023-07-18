//
//  ContentView.swift
//  SwiftUISearchBar
//
//  Created by shiyanjun on 7/18/23.
//

import SwiftUI

struct ContentView: View {
    // 关注者列表
    @State private var followers: [Follower] = []
    // 搜索关键字
    @State private var seachText: String = ""
    
    // 搜索过滤列表
    var filteredFollowers: [Follower] {
        // 搜索关键字为空时返回原列表
        guard !seachText.isEmpty else { return followers }
        // 匹配搜索关键字，不区分大小写
        return followers.filter { $0.login.localizedCaseInsensitiveContains(seachText) }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredFollowers, id: \.id) { follower in
                HStack(spacing: 20) {
                    // 异步展示头像
                    AsyncImage(url: URL(string: follower.avatarUrl)!) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                    } placeholder: {
                        // 缺省头像
                        Image(systemName: "photo.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 44, height: 44)
                    
                    // 用户名
                    Text(follower.login)
                        .font(.title3)
                        .fontWeight(.medium)
                }
            }
            .navigationTitle("Followers")
            .listStyle(.plain)
            // 请求Github API，加载关注者列表
            .task { followers = await getFollowers() }
            // 搜索框
            .searchable(text: $seachText, prompt: "Search Followers")
        }
    }
    
    // 从Github API查询关注者列表（https://docs.github.com/zh/rest/users/followers?apiVersion=2022-11-28#list-followers-of-a-user）
    func getFollowers() async -> [Follower] {
        print("Request Github API...")
        // URL中的xuebusi是我的Github用户名，可以改成你自己的
        let url = URL(string: "https://api.github.com/users/xuebusi/followers?per_page=100")!
        let (data, _) = try! await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        // 字段名称下划线转驼峰
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try! decoder.decode([Follower].self, from: data)
    }
}

// 关注者
struct Follower: Decodable, Identifiable {
    var id: Int
    var login: String
    var avatarUrl: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
