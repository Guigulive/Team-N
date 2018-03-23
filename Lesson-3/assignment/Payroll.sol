pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {
    using SafeMath for uint;
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;

    uint totalSalary;
    //address owner;
    mapping(address => Employee) public employees;

    modifier employeeExist(address employeeId){
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }
    
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary
            .mul(now.sub(employee.lastPayday))
            .div(payDuration);
        employee.id.transfer(payment);
    }

    function addEmployee(address employeeId, uint salary) onlyOwner{
        var employee = employees[employeeId];
        
        totalSalary = totalSalary.add(salary * 1 ether);
        employees[employeeId] = Employee(employeeId,salary * 1 ether,now);
    }
    
    function addEmployeeWithLastPayday(address employeeId, uint salary, uint lastPayday) onlyOwner{
        var employee = employees[employeeId];
        
        totalSalary = totalSalary.add(salary * 1 ether);
        employees[employeeId] = Employee(employeeId,salary * 1 ether,lastPayday);
    }
    
    function removeEmployee(address employeeId) onlyOwner{
        var employee = employees[employeeId];
        assert(employee.id != 0x0);

        _partialPaid(employee);
        totalSalary = totalSalary.sub(employee.salary);
        delete employees[employeeId];
    }
    
    function updateEmployee(address employeeId, uint salary) onlyOwner{
        var employee = employees[employeeId];
        assert(employee.id != 0x0);

        _partialPaid(employee);
        totalSalary = totalSalary.sub(employees[employeeId].salary);
        employees[employeeId].salary = salary * 1 ether;
        totalSalary = totalSalary.add(salary * 1 ether);
        employees[employeeId].lastPayday = now;
    }
    
    function changePaymentAddress(address oldEmployeeId, address newEmployeeId) onlyOwner{
        var oldEmployee = employees[oldEmployeeId];
        assert(oldEmployee.id != 0x0);
        
        addEmployeeWithLastPayday(newEmployeeId,oldEmployee.salary,oldEmployee.lastPayday);
        delete employees[oldEmployeeId];
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance.div(totalSalary);
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() employeeExist(msg.sender){
        var employee = employees[msg.sender];

        uint nextPayday =  employee.lastPayday.add(payDuration);
        assert(nextPayday < now);
        
        employees[msg.sender].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}
