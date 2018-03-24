pragma solidity ^0.4.14;

contract Payroll {
    uint constant payDuration = 10 seconds;

    address owner;
    uint salary;
    address employee;
    uint lastPayday;

    function Payroll() {
        owner = msg.sender;
    }

    function updateEmployee(address e, uint s) {
        require(msg.sender == owner);
        employee = e;
        salary = s * 1 ether;
        lastPayday = now;

        if (employee != 0x0) {
            uint payment = salary * (now - lastPayday) / payDuration;
            employee.transfer(payment);
        }
    }

    function addFund() payable returns (uint) {
        require(msg.sender == owner);
        return this.balance;
    }

    function getPaid() {
        require(msg.sender == employee);

        uint nextPayday = lastPayday + payDuration;
        assert(nextPayday < now);

        lastPayday = nextPayday;
        employee.transfer(salary);
    }

    function updatePayDuration(uint payDuration) {
        require(msg.sender == owner);
        this.payDuration = payDuration;
        lastPayday = now;
        if (employee != 0x0) {
            uint payment = salary * (now - lastPayday) / payDuration;
            employee.transfer(payment);
        }
    }
}
