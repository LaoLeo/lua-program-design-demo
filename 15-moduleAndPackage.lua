local m = require "io"
m.write("module")

-- local m1 = require("13-metatable-metamethod")
-- print(m1.days[1])

-- require的抽象函数，实现逻辑
function require(name)
    if not package.loaded[name] then
      local loader = findloader(name) -- 抽象函数
      if loader == nil then
        error("unable to load module"..name)
      end
      package.loaded[name] = true -- 假如一个模块调用另一个模块，而后者又要加载前者，那么标志为true就会立即返回，避免无限循环
      local res = loader(name)
      if res ~= nil then
        package.loaded[name] = res
      end
    end
    return package.loaded[name]
end

complex = {}
function complex.new(r, i) return {r=r, i=i} end
complex.i = complex.new(0, 1)
function complex.add(c1, c2)
    return complex.new(c1.r + c2.r, c1.i+c2.i)
end
function  complex.sub(c1, c2)
    return complex.new(c1.r-c2.r, c1.i-c2.i)
end
function complex.mul(c1, c2)
    return complex.new(c1.r*c2.r - c1.i*c2.i,  c1.r*c2.i - c1.i*c2.r)
end
local function inv(c) 
  local n = c.r^2 + c.i^2   
  return complex.new(c.r/n, -c.i/n)
end
function complex.div(c1, c2)
    return complex.mul(c1, inv(c2))
end
return complex


-- 换种方式挂在模块
-- local modname = ...
-- local M = {}
-- _G[modname] = M
-- M.i = {r=0, i=1}

-- 不用写return
-- local modname = ...
-- local M = {}
-- _G[modname] = M
-- package.loaded[modname] = M

-- 创建模块，漏写了local 也不会污染全局
-- local modname = ...
-- local M = {}
-- _G[modname] = M
-- package.loaded[modname] = M
-- setfenv(1, M)

-- 继承全局
-- local modname = ...
-- local M = {}
-- _G[modname] = M
-- package.loaded[modname] = M
-- setmetatable(M, {__index = _G})
-- setfenv(1, M)


