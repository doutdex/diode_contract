// Diode Contracts
// Copyright 2020 IoT Blockchain Technology Corporation LLC (IBTC)
// Licensed under the Diode License, Version 1.0
pragma solidity ^0.6.5;
import "./ProxyResolver.sol";

contract ManagedProxy {
    bytes32 immutable ref;
    ProxyResolver immutable resolver;

    constructor(ProxyResolver _resolver, bytes32 _ref) public {
        ref = _ref;
        resolver = _resolver; 
    } 

    fallback() external payable {
        address target = resolver.resolve(ref);
        assembly {
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(gas(), target, 0x0, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())
            switch result case 0 {revert(0, 0)} default {return (0, returndatasize())}
        }
    }
}