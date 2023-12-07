def withdraw(amount):
    quarters_dispense = amount // 25
    amountAfterQuarters = amount - (quarters_dispense * 25)

    dimes_dispense = amountAfterQuarters // 10
    amountAfterDimes = amountAfterQuarters - (dimes_dispense * 10)

    nickels_dispense = amountAfterDimes // 5
    amountAfterNickels = amountAfterDimes - (nickels_dispense * 5)

    pennies_dispense = amountAfterNickels

    return quarters_dispense, dimes_dispense, nickels_dispense, pennies_dispense

quarters, dimes, nickels, pennies = withdraw(143)
print("Quarters: " + str(quarters))
print("Dimes: " + str(dimes))
print("Nickels: " + str(nickels))
print("Pennies: " + str(pennies))
