Account = {balance = 0}
function Account.withdraw(self, v)
  if v > self.balance then error"insufficient funds" end
  self.balance = self.balance - v
end
function Account:deposit(v)
  self.balance = self.balance + v
end
function Account:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

a = Account:new{balance = 0}
a:deposit(100.00)
-- 等于
getmetatable(a).__index.deposit(a, 100.00)
-- 等于
Account.deposit(a, 100.00)


-- 继承
SpecialAccount = Account:new()
s = SpecialAccount:new{limit = 1000}
function SpecialAccount:withdraw(v)
  if v - self.balance >= self:getLimit() then
    error"insufficient funds"
  end
  self.balance = self.balance - v
end

function SpecialAccount:getLimit()
  return self.limit or 0
end

s:withdraw(999)
-- s:withdraw(1000)

function s:getLimit()
    return 10000
end 

s:withdraw(1000)


-- 多重继承
local function search(k, plist)
    for i=1, #plist do
      local v = plist[i][k]
      if v then return v end
    end
end

function createClass(...)
    local c = {}
    local parents = {...}

    setmetatable(c, { __index = function (t, k)
      return search(k, parents)
    end })

    c.__index = c
    function c:new(o)
        o = o or {}
        setmetatable(o, c)
        return o
    end

    return c
end

Named = {}
function Named:getName()
    return self.name
end
function Named:setName(name)
    self.name = name
end

NamedAccount = createClass(Account, Named)
account = NamedAccount:new{name="AlexLao"}
print(account:getName())


-- 私密性
function newAccount(initialBalance)
    local self = {balance = initialBalance, LIM = 10000.00}

    local withdraw = function (v)
        self.balance = self.balance - v
    end

    local deposit = function (v)
      self.balance = self.balance + v
    end

    local extra = function ()
        if self.balance >= self.LIM then
          return self.balance*0.10
        else
          return 0
        end
    end

    local getBalance = function ()
        return self.balance + extra()
    end

    return {
      withdraw = withdraw,
      deposit = deposit,
      getBalance = getBalance
    }
end
acc1 = newAccount(10099.00)
acc1.withdraw(99)
print(acc1.getBalance())
