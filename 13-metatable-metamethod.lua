

print("========================")
print("========================")
print("第13章 元表和元方法")
print("========================")
print("========================")
print("\n\n")


print("---------------算术类元方法----------------")
Set = {}
local mt = {}
function Set.New(l)
    local set = {}
    setmetatable(set, mt)
    for _, v in ipairs(l) do set[v] = true end
    return set
end
function Set.union(a, b)
    local res = Set.New{}
    for k in pairs(a) do res[k] = true end
    for k in pairs(b) do res[k] = true end
    return res
end
function Set.intersection(a, b)
    local res = Set.New{}
    for k in pairs(a) do
      res[k] = b[k]
    end
  return res
end
function Set.tostring(set)
    local l = {}
    for e in pairs(set) do
      l[#l+1] = e
    end
    return "{"..table.concat( l, ", ").."}"
end
function Set.print(s)
    print(Set.tostring(s))
end
mt.__add = Set.union
mt.__mul = Set.intersection

s1 = Set.New({10, 20 ,30, 40, 2})
s2 = Set.New({10, 80, 200, 2})
Set.print(s1+s2)
Set.print(s1*s2)

mt.__le = function (a, b) 
  for k in pairs(a) do
    if not b[k] then return false end
  end
  return  true
end
mt.__lt = function (a, b)
    return a <= b and not (b<=a)
end
    
mt.__eq = function (a, b)
    return a <= b and b <=a 
end
s1 = Set.New({1, 3})
s2 = Set.New({1, 3, 4})
print(s1 < s2)
print(s1 > s2)
print(s1 <= s2)
print(s1 >= s2)
print(s1 == s2)

print("------------------print原理------------------------")
mt.__tostring = Set.tostring
s1 = Set.New({1, 4, 5})
print(s1)

print("------------------protected table------------------------")
mt.__metatable = "not your business"
print(getmetatable(s1))
-- setmetatable(s1, {})
print("---------------算术类元方法 end----------------")


print("---------------__index元方法----------------")
Window={}
Window.prototype = {x=0, y=0, width=100, height=100}
Window.mt = {}
function Window.new(o)
    setmetatable(o, Window.mt)
    return o
end
Window.mt.__index = function (table, key)
  return Window.prototype[key]
end
-- Window.mt.__index = Window.prototype

w = Window.new{x=10, y=20}
print(w.width)

print("-- __newindex元方法")
mtni = {}
Window.mt.__newindex = mtni
w.color = "red"
Set.print(mtni)
Set.print(w)
print("-- 不涉及任何元方法直接设置table")
rawset(w, "color", "blue")
Set.print(w)

print("---------------__index end----------------")

print("---------------默认值table----------------")
function setDefault(t, d)
    local mt = {__index = function () 
          return d
    end}
    setmetatable(t, mt)
end
tab = {x=10, y=20}
print(tab.x, tab.z)
setDefault(tab, 0)
print(tab.x, tab.z)

print("-- 将默认值放入自身table中")
local mt = {__index=function (t)
    return t.___
end}
function setDefault(t, d)
  t.___ = d
  setmetatable(t, mt)
end
setDefault(tab, 1)
print(tab.x, tab.z)

print("-- 使用唯一key避免命名冲突")
local key = {}
mt = {__index=function (t)
  return t[key]
end}
function setDefault(t, d)
  t[key] = d
  setmetatable(t, mt)
end
setDefault(tab, 2)
print(tab.x, tab.z)
print("---------------默认值table end----------------")

print("---------------跟踪table的访问----------------")
t = {}
local _t = t
t = {}
local mt = {
  __index =function (t, k)
      print("*access to element " .. tostring(k))
      return _t[k]
  end,
  __newindex = function (t, k, v)
      print("*update of element "..tostring(k) .. " to" .. tostring(v))
      _t[k] = v
  end
}
setmetatable(t, mt)
t[2] = "hello"
print(t[2])

print("-- 使用私有索引 和 工厂函数生成代理")
local index = {}
local mt = {
  __index =function (t, k)
      print("*access to element " .. tostring(k))
      return t[index][k]
  end,
  __newindex = function (t, k, v)
      print("*update of element "..tostring(k) .. " to" .. tostring(v))
      t[index][k] = v
  end
}
function track(t)
    local proxy = {}
    proxy[index] = t
    setmetatable(proxy, mt)
    return proxy
end
t = track{x = 10}
print(t.x)
print("---------------跟踪table的访问 end----------------")


print("---------------只读table----------------")
function readOnly(t)
    local proxy = {}
    local mt = {
      __index = t,
      __newindex =function (t, k, v)
          error("attemp to update a read-only table", 2)
      end
    }
    setmetatable(proxy, mt)
    return proxy
end
days = readOnly{"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
print(days[1])
days[1] = "sss"

print("---------------只读table end----------------")