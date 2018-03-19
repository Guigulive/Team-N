pragma solidity ^0.4.14;

/* add quotes to the address when debug in remix */

contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;
    address owner;
    Employee[] employees;
    
    uint private totalSalary = 0;
    
    
    function Payroll() {
        owner = msg.sender;
    }

    // only owner can access
    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
    
    function _partialPaid(Employee storage employee) private {
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        _payEmployee(employee, payment, now);
    }
    
    // pay employee
    function _payEmployee(Employee storage employee, uint payment, uint time) private{
        employee.lastPayday = time;
        employee.id.transfer(payment);
    }
    
    
    function _findEmployee(address employeeId) private returns (Employee, uint) {
        for (uint i=0; i<employees.length; i++){
            if(employees[i].id == employeeId){
                return (employees[i], i);
            }
        }
    }

    function addEmployee(address employeeId, uint salary) onlyOwner {
        var (employeeTemp, ) = _findEmployee(employeeId);
        if (employeeTemp.id == 0x0) {
            Employee memory employee = Employee(employeeId, salary * 1 ether, now);
            employees.push(employee);
            totalSalary += employee.salary;
        }
    }
    
    function removeEmployee(address employeeId) onlyOwner{
        var (employee, index) = _findEmployee(employeeId);
        if (employee.id != 0x0) {
            _partialPaid(employees[index]);
            totalSalary -= employees[index].salary;
            delete employees[index];
            employees[index] = employees[employees.length - 1];
            employees.length -= 1;
        }
    }
    
    function updateEmployee(address employeeId, uint salary) onlyOwner {
        var (employee, index) = _findEmployee(employeeId);
        if (employee.id != 0x0) {
            _partialPaid(employees[index]);
            totalSalary = totalSalary - employee.salary + salary * 1 ether;
           employees[index].salary = salary * 1 ether;
        }
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() {
        var (employee, index) = _findEmployee(msg.sender);
        if (employee.id != 0x0) {
             uint nextPayday = employee.lastPayday + payDuration;
             if(nextPayday > now){
                revert();
            }
            _payEmployee(employees[index], employee.salary, nextPayday);
        }
    }
    
}