local tb = {
	[1] = "hello",
	[2] = "world",
	[3] = "i am worker",
	[4] = "hao are you",
}


table.insert(tb, 1, "zhangsan")

print(table.unpack(tb))

print(1.00 == 1)