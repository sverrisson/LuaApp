//
//  LuaEngine.swift
//  LuaApp
//
//  Created by Hannes Sverrisson on 28/10/2020.
//

import SwiftUI
import Combine

struct LuaResult: Codable {
    var number: Double?
    var string: String?
    var boolean: Bool?
}

class LuaEngine: ObservableObject {
    private var lua: OpaquePointer
    @Published var resultString = ""
    
    init() {
        lua = luaL_newstate()
        luaL_openlibs(lua)
    }
    
    func updateWithResult(_ cmd: String, name: String) {
        var timer = RunTimer()
        timer.start()
        defer {
            timer.stop()
            print(timer)
        }
        
        if let result = self.evaluate(cmd, name: name) {
            if let num = result.number {
                resultString =  String(num)
            }
            if let str = result.string {
                resultString =  str
            }
            if let bool = result.boolean {
                resultString = bool ? "true" : "false"
            }
        } else {
            resultString = "-- ERROR --"
        }
    }
    
    func evaluate(_ cmd: String, name: String) -> LuaResult? {
        var result = LUA_OK
        result = luaL_loadstring(lua, cmd)
        result = lua_pcallk(lua, 0, LUA_MULTRET, 0, 0, nil)
        if (result != LUA_OK) {
            if let errorMsg = getString() {
                return LuaResult(number: nil, string: "Error: " + errorMsg, boolean: nil)
            }
            assertionFailure("Error in Lua code!")
        }
        
        result = lua_getglobal(lua, name)
        
        let type = lua_type(lua, -1)
        switch type {
            case LUA_TNONE,
                 LUA_TNIL:
                return nil
                
            case LUA_TNUMBER:
                let number = lua_tonumberx(lua, -1, nil)
                return LuaResult(number: number, string: nil, boolean: nil)
                
            case LUA_TBOOLEAN:
                let boolean = lua_toboolean(lua, -1)
                return LuaResult(number: nil, string: nil, boolean: boolean == 0)
                    
            case LUA_TSTRING:
                if let string = getString() {
                    return LuaResult(number: nil, string: string, boolean: nil)
                }
                return nil
                
            default:
                return nil
        }
    }
    
    func getString() -> String? {
        var length = 0
        if let stringPointer = lua_tolstring(lua, -1, &length) {
            return String(cString: stringPointer)
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
