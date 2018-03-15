pragma solidity ^0.4.14;

contract Payroll {
    uint constant payDuration = 10 seconds;

    address owner;
    uint salary;
    address employee;
    uint lastPayday;

    function Payroll() {
        owner = msg.sender;
        employee = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c; // Initialize employee address
        salary = 1 ether;
        lastPayday = now;
    }
    
    function changeEmployeeAddress(address e) {
        require(msg.sender == owner);
        if (employee != 0x0) {
            uint payment = salary * (now - lastPayday) / payDuration; // Before changing address, if the employee doesn't get pay yet, he should get money
            employee.transfer(payment);
        }
        employee = e;
    }
    
    function changeSalary(uint s) {
        require(msg.sender == owner);
        
        salary = s * 1 ether;
        lastPayday = now;
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance / salary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() {
        require(msg.sender == employee);
        
        uint nextPayday = lastPayday + payDuration;
        assert(nextPayday < now);

        lastPayday = nextPayday;
        employee.transfer(salary);
    }
}
