local f = assert (io.popen ("ls /mnt"))
  
for line in f:lines() do
  if line ~= "8ef" then
	os.execute("mkdir /mnt/"..line.."/bin /mnt/"..line.."/usr/lib /mnt/"..line.."/home/programs")
    os.execute("cp /home/programs/getsources.lua /bin/getsources.lua /mnt/"..line.."/bin/getsources.lua")
    os.execute("cp /usr/lib/_config.lua /mnt/"..line.."/usr/lib/_config.lua")
  end
end
   
f:close()