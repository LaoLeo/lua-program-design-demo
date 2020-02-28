
print("========================")
print("========================")
print("第9章 协同程序")
print("========================")
print("========================")
print("\n\n")




co = coroutine.create( function() print("co") end )
print(co)
print(coroutine.status( co ))
coroutine.resume( co )
print(coroutine.status( co ))

co = coroutine.create( function()
  for i=1, 3 do
    print("co", i)
    coroutine.yield()
  end
end
)
print("------------yeild------------------")
coroutine.resume( co )
print(coroutine.status( co ))
coroutine.resume( co )
print(coroutine.status( co ))
coroutine.resume( co )
print(coroutine.status( co ))
print(coroutine.resume( co ))
print(coroutine.status( co ))
print("------------yeild end------------------")


print("------------resume-yeild------------------")
co = coroutine.create( function(a, b, c)
  print("co", a, b, c)
end
)
print(coroutine.resume( co,1, 3, 4 ))
co = coroutine.create( function(a, b)
  coroutine.yield( a+b, a-b )
end
)
print(coroutine.resume( co,20, 10 ))
co = coroutine.create( function(a, b)
  return a, b
end
)
print(coroutine.resume( co,20, 10 ))
print("------------resume-yeild end------------------")


print("------------消费者驱动-----------------")
function producer()
  while true do
      local x = io.read()
      send(x) -- 发送给生产者
  end
end
producer = coroutine.create( function()
  while true do
      local x = io.read()
      send(x) -- 发送给生产者
  end
end)

function consumer()
  while true do
      local x = receive()
      io.write(x, "\n")
  end
end

function send(x)
  coroutine.yield(x)
end

function receive()
  local status, value = coroutine.resume(producer)
  return value
end

-- consumer()
print("------------消费者驱动 end-----------------")

print("------------管道pipe与过滤器-----------------")
function receive(prod)
  local status, value = coroutine.resume(prod)
  return value
end
function producer()
    return coroutine.create( function()
      while true do
          local x = io.read()
          send(x) -- 发送给生产者
      end
    end)
end
function filter(prod)
  return coroutine.create(function ()
    for line=1, math.huge do
      local x = receive(prod)
      x = string.format( "%5d %s",line, x)
      send(x) --将新值发给消费者
    end 
  end)
end
function consumer(prod)
  while true do
      local x = receive(prod)
      io.write(x, "\n")
  end
end

-- consumer(filter(producer()))

print("------------管道pipe与过滤器 end-----------------")

print("------------以协同程序实现迭代器-----------------")
function permgen(a, n)
  n = n or #a
  if n <= 1 then
    coroutine.yield(a)
  else
    for i=1, n do
      a[n], a[i] = a[i], a[n]
      permgen(a, n - 1)
      a[n], a[i] = a[i], a[n]
    end
  end
    
end

function permutations(a)
    local co = coroutine.create(function ()
        permgen(a)
    end)
    return function ()
        local code, res = coroutine.resume(co)
        return res
    end
end

function printResult(a)
  for i=1, #a do
    io.write(a[i], " ")
  end
  io.write("\n")
end
-- permgen{1, 2, 3, 4}
for r in permutations({"a", "b", "c"}) do
  -- printResult(r)
end

print("------------以协同程序实现迭代器 end-----------------")

print("------------非抢先式的多线程-----------------")
require("socket")
host = "www.baidu.com"
file="/index.html"
c=assert(socket.connect(host, 80))
c:send("GET"..file.."HTTP/1.0\r\n\r\n")
while true do
  local s, status, partial = c:receive(2^10)
  io.write(s or partial)
  if status == "closed" then break end
end
c:close()

function download(host, file)
    local c = assert(socket.connect(host, 80))
    local count = 0
    c:send("GET"..file.."HTTP/1.0\r\n\r\n")
    while true do
        local s, status, partial = receive(c)
        count = count + #(s or partial)
        if status == "closed" then break end
    end
    c:close()
    print(file, count)
end
function receive(connection)
  connection:settimeout(0)
  local s, status, partial = connection:receive(2^10)
  if status == "timeout" then
    coroutine.yield( connection )
  end
  return s or partial, status
    
end

threads = {}
function get(host, file)
  local co = coroutine.create(function ()
    download(host, file)
  end)
  table.insert( threads, co)
    
end

function dispatch()
    local i = 1
    while true do
        if threads[i] == nil then
          if threads[1] == nil then break end
          i = 1
        end
        local status, res = coroutine.resume( threads[i] )
        if not res then
          table.remove(threads, i)
        else 
          i = i+1
        end
    end
end
host = "www.w3.org"
get(host, "/TR/html401/html40.txt")
get(host, "/TR/2002/REC-xhtml1-20020801/xhtml.pdf")
get(host, "/TR/2002/REC-xhtml1-20020801/xhtml.pdf")
get(host, "/TR/REC-xhtml32.html")
get(host, "/TR/2000/REC-DOM-Level-2-Core-20001113/DOM2-Core.txt")

dispatch()

print("------------非抢先式的多线程 end-----------------")