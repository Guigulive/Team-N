pragma solidity ^0.4.14;

/* add quotes to the address when debug in remix */

contract Payroll {
    uint constant payDuration = 10 seconds;
    address public owner = msg.sender;
    uint salary = 1 ether;
    address employee;
    uint lastPayday = now;

    // only owner can access
    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
    
    // only employee can access
    modifier onlyEmployee {
        require (employee != 0x0 && msg.sender == employee);
        _;
    }
    
    // recoup all of the rest payment  
    function _recoupIfNecessary() private {
        if (employee != 0x0) {
            uint payment = salary * (now - lastPayday) / payDuration;
            _pay_employee(payment, now);
        }
    }
    
    // pay employee
    function _pay_employee(uint payment, uint time) private{
        employee.transfer(payment);
        lastPayday = time;
    }
    
    function updateEmployeeAddr(address new_addr) onlyOwner returns (address) {
        updateEmployee(new_addr, 0);
        return employee;
    }
    
    function updateEmployeeSalary(uint new_salary) onlyOwner returns (uint) {
        // if the employee exists then recoup payment first
        updateEmployee(0x0, new_salary);
        return salary;
    }
    
    function updateEmployee(address new_addr, uint new_salary) onlyOwner returns (address, uint) {
        // if the employee exists then recoup payment first
        _recoupIfNecessary();
        if (new_addr != 0x0) {
            employee = new_addr;
        }
        if (new_salary > 0) {
            salary = new_salary * 1 ether;
        }
        return (employee, salary);
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
    
    function getPaid() onlyEmployee {
        uint nextPayday = lastPayday + payDuration;
        if(nextPayday > now){
            revert();
        }
        _pay_employee(salary, nextPayday);
    }
}