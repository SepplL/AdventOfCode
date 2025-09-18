import re

number = 0

with open("input.txt", "r") as file:
    for line in file:
        currNum = ""
        numList = re.findall(f'\d+', line)
        print(line)
        if len(numList[0]) == 1:
            currNum += numList[0]
        else:
            nums = [str(i) for i in numList[0]]
            currNum += nums[0]

        if len(numList[-1]) == 1:
            currNum += numList[-1]
        else:
            nums = [str(i) for i in numList[-1]]
            currNum += nums[-1]

        number += int(currNum)

print(number)
