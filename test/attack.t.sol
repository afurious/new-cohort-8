// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SecureBank} from "../src/security.sol";
import {AttackContract} from "../src/Attack.sol";

contract SecureBankTest is Test {
    SecureBank bank;
    AttackContract attack;
    address user1;
    address attacker;

    function setUp() public {
        user1 = address(0x1);
        attacker = address(0x2);

        bank = new SecureBank();
        attack = new AttackContract(address(bank));

        vm.deal(user1, 10 ether);
        vm.prank(user1);
        bank.deposit{value: 10 ether}();
    }

    function testDepositAndWithdraw() public {
        uint256 beforeBalance = user1.balance;
        vm.prank(user1);
        bank.withdraw(5 ether);
        uint256 afterBalance = user1.balance;

        assertGt(afterBalance, beforeBalance);
        assertEq(bank.balances(user1), 5 ether);
    }

    function testRevertsReentrancyGuard() public {
        vm.deal(attacker, 1 ether);
        vm.prank(attacker);
        vm.expectRevert("No reentrancy");
        attack.attack{value: 1 ether}();
    }

    function testFundsIntactAfterAttack() public {
        vm.deal(attacker, 1 ether);
        vm.prank(attacker);
        try attack.attack{value: 1 ether}() {} catch {}

        uint256 bankBalance = address(bank).balance;
        assertGe(bankBalance, 10 ether);
    }

    function testDepositAndWithdraw() public {
        uint256 beforeBalance = user1.balance;
        vm.prank(user1);
        bank.withdraw(5 ether);
        uint256 afterBalance = user1.balance;

        assertGt(afterBalance, beforeBalance);
        assertEq(bank.balances(user1), 5 ether);
    }

    function testRejectsWithdraw() public {
        vm.prank(user1);
        vm.expectRevert("Insufficient balance");
        bank.withdraw(999 ether);
    }
}
