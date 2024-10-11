// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Test } from 'forge-std/Test.sol';
import { DealFactory } from '../../src/DealFactory.sol';

contract DealFactoryTest is Test {
    DealFactory factory; 

    function setUp() external { 
        factory = new DealFactory();
    }

    function testOwnerIsMsgSender() public {
        assertEq(factory.getOwner(), address(this));
    }
}