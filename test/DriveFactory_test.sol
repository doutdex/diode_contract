pragma solidity ^0.6.5;
import "./Assert.sol";
import "./CallForwarder.sol";
import "../contracts/DriveFactory.sol";
import "../contracts/Drive.sol";

contract Drive2 is Drive {
    function Version() external override pure returns (int256) {
        return 200;
    }
}

contract Dummy {
}

contract DriveFactoryTest {
    Drive version1;
    Drive version2;
    address number1;
    DriveFactory factory;

    constructor() public {
        version1 = new Drive();
        version2 = new Drive2();
        factory = new DriveFactory();
    
        number1 = address(new Dummy());
    }

    function checkCreate2() public {
        bytes32 salt = hex"0011001100110011001100110011001100110011001100110011001100110011";
        address should = factory.Create2Address(salt);
        address raw = factory.Create(payable(address(this)), salt, address(version1));

        Assert.notEqual(raw, address(0), "Create2() should not return 0");
        Assert.equal(raw, should, "Create2() and Create2Address() should return the same address");

        Drive drive = Drive(raw);

        drive.AddMember(number1, RoleType.Admin);

        // Factory created contract should work normally
        Assert.equal(drive.Version(), 100, "Version() should be equal 100");
        acceptanceTest(drive);

        // Upgrade
        factory.Upgrade(salt, address(version2));
        
        // and test again
        Assert.equal(drive.Version(), 200, "Version() should be equal 200");
        acceptanceTest(drive);
    }

    function acceptanceTest(Drive drive) internal {
        Assert.equal(address(this), drive.owner(), "address(this) should be owner");
        Assert.ok(drive.Role(address(this)) == RoleType.Owner, "address(this) should be RoleType.Owner");
        drive.AddMember(number1, RoleType.Admin);

        address[] memory members = drive.Members();
        Assert.equal(members.length, 1, "Members() should return one member");
        Assert.equal(members[0], number1, "Members() should return [number1]");
    }
}
