pragma solidity ^0.4.14;

contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }

    uint constant payDuration = 10 seconds;

    uint totalSalary;
    address owner;
    Employee[] employees;

    function Payroll() {
        owner = msg.sender;
        totalSalary = 0;
    }

    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.id.transfer(payment);
    }

    function _findEmployee(address employeeId) private returns (Employee, uint) {
        for (uint i = 0; i < employees.length; i++) {
            if (employees[i].id == employeeId) {
                return (employees[i], i);
            }
        }
    }

    function addEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id == 0x0);

        employees.push(Employee(employeeId, salary * 1 ether, now));
        //when adding a new employee, update the totalSalary
        totalSalary += salary * 1 ether;
    }

    function removeEmployee(address employeeId) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);

        //when remoing an employee, update the totalSalary
        totalSalary -= employee.salary;
        _partialPaid(employee);
        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
    }

    function updateEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);

        _partialPaid(employee);
        //when updating an employee's salary, update the totalSalary
        totalSalary = totalSalary + salary * 1 ether - employees[index].salary;
        employees[index].salary = salary * 1 ether;
        employees[index].lastPayday = now;
    }

    function addFund() payable returns (uint) {
        return this.balance;
    }

    function calculateRunway() returns (uint) {
        /*uint totalSalary = 0;
        for (uint i = 0; i < employees.length; i++) {
            totalSalary += employees[i].salary;
        }*/
        return this.balance / totalSalary;
    }

    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() {
        var (employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);

        uint nextPayDay = employee.lastPayday + payDuration;
        assert(nextPayDay < now);

        employees[index].lastPayday = nextPayDay;
        employee.id.transfer(employee.salary);
    }
}
