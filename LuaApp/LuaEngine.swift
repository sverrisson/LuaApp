//
//  LuaEngine.swift
//  LuaApp
//
//  Created by Hannes Sverrisson on 28/10/2020.
//

import SwiftUI
import Combine

struct LuaResult: Codable {
    var number: lua_Number?
    var string: String?
}

class LuaEngine: ObservableObject {
    private var lua: OpaquePointer
    @Published var resultString = ""
    
    init() {
        lua = luaL_newstate()
    }
    
    func updateWithResult(_ cmd: String, name: String) {
        if let result = self.evaluate(cmd, name: name), let number = result.number {
            resultString = String(number)
        } else {
            resultString = "-- ERROR --"
        }
    }
    
    func evaluate(_ cmd: String, name: String) -> LuaResult? {
        var result = LUA_OK
        while (result == LUA_OK) {
            result = luaL_loadstring(lua, cmd)
            result = lua_pcallk(lua, 0, LUA_MULTRET, 0, 0, nil)
            lua_getglobal(lua, name)
            if ((lua_isnumber(lua, -1)) != 0) {
                let number = lua_tonumberx(lua, -1, nil)
                return LuaResult(number: number, string: nil)
            }
        }
        if (result != LUA_OK) {
            assertionFailure("Error in Lua code!")
        }
        return nil
    }
    
    deinit {
        lua_close(lua)
    }
    
    func test() {
        // Get input and update engine
        let cmd = "a = 7 + 35"
        var result = luaL_loadstring(lua, cmd.cString(using: .ascii))
        result = lua_pcallk(lua, 0, LUA_MULTRET, 0, 0, nil)
        if (result == LUA_OK) {
            lua_getglobal(lua, "a")
            if ((lua_isnumber(lua, -1)) != 0) {
                let number = lua_tonumberx(lua, -1, nil)
                assert(number == 42, "Not working")
            }
        }
    }
}
